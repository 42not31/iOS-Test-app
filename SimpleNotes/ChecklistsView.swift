import SwiftUI
import SwiftData

struct ChecklistsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChecklistItem.createdAt, order: .reverse) private var items: [ChecklistItem]
    @State private var newTitle = ""
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var selectedPriority = 0

    private let priorities = ["Normal", "High", "Urgent"]
    private let priorityIcons = ["circle", "exclamationmark.circle", "flame.fill"]
    private let priorityColors: [Color] = [Color(hex: "00D2FF"), Color(hex: "FFB703"), Color(hex: "FF477E")]

    private var categories: [String] {
        let s = Set(items.map { $0.category.isEmpty ? "General" : $0.category })
        return ["All"] + s.sorted()
    }
    private var filtered: [ChecklistItem] {
        items.filter { i in
            let mSearch = searchText.isEmpty || i.title.localizedCaseInsensitiveContains(searchText)
            let mCat = selectedCategory == "All" || i.category == selectedCategory || (selectedCategory == "General" && i.category.isEmpty)
            return mSearch && mCat
        }
    }
    private var done: Int { items.filter(\.isCompleted).count }
    private var progress: Double { items.isEmpty ? 0 : Double(done)/Double(items.count) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        ProgressRing(progress: progress, size: 52, tint: Color(hex: "00D2FF"))
                            .overlay { Text("\(Int(progress*100))%").font(.caption2.bold().monospacedDigit()) }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(done) of \(items.count) completed").font(.subheadline.weight(.medium))
                            ProgressView(value: progress).tint(Color(hex: "00D2FF"))
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    HStack {
                        TextField("Add a task...", text: $newTitle).onSubmit { add() }
                        Menu {
                            ForEach(0..<3, id: \.self) { i in
                                Button { selectedPriority = i } label: { Label(priorities[i], systemImage: priorityIcons[i]) }
                            }
                        } label: {
                            Image(systemName: priorityIcons[selectedPriority]).foregroundStyle(priorityColors[selectedPriority])
                                .padding(6).background { Circle().fill(priorityColors[selectedPriority].opacity(0.14)) }
                        }
                        Button(action: add) {
                            Image(systemName: "arrow.up.circle.fill").font(.title2)
                                .foregroundStyle(newTitle.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary.opacity(0.4) : Color(hex: "00D2FF"))
                        }.disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                if !categories.isEmpty {
                    Section {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { c in Text(c).tag(c) }
                        }.pickerStyle(.segmented)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }

                Section {
                    if filtered.isEmpty {
                        ContentUnavailableView(
                            items.isEmpty ? "No Tasks" : "No Results",
                            systemImage: "checklist",
                            description: Text(items.isEmpty ? "Add a task above to get started." : "Try a different search or category.")
                        ).listRowBackground(Color.clear).listRowSeparator(.hidden)
                    } else {
                        ForEach(filtered) { item in row(item) }
                    }
                } header: {
                    if !filtered.isEmpty { Text("\(filtered.count) tasks") }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Checklist")
            .searchable(text: $searchText, prompt: "Search tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            for i in items where i.isCompleted { modelContext.delete(i) }
                        } label: { Label("Clear Completed", systemImage: "trash") }.disabled(done == 0)
                    } label: { Image(systemName: "ellipsis.circle") }
                }
            }
        }
    }

    private func row(_ item: ChecklistItem) -> some View {
        let tint = priorityColors[min(item.priority, 2)]
        return HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { item.isCompleted.toggle() }
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3).foregroundStyle(item.isCompleted ? tint : .secondary)
            }.buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title).font(.body).strikethrough(item.isCompleted).foregroundStyle(item.isCompleted ? .secondary : .primary).lineLimit(2)
                HStack(spacing: 6) {
                    Label(priorities[min(item.priority,2)], systemImage: priorityIcons[min(item.priority,2)])
                        .font(.caption2.weight(.semibold)).foregroundStyle(tint)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background { Capsule().fill(tint.opacity(0.12)) }
                    if !item.category.isEmpty && item.category != "General" {
                        Text(item.category).font(.caption2).foregroundStyle(.secondary)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background { Capsule().fill(Color(.secondarySystemBackground)) }
                    }
                }
            }
            Spacer()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) { withAnimation { modelContext.delete(item) } } label: { Label("Delete", systemImage: "trash") }
        }
        .swipeActions(edge: .leading) {
            Button { item.isCompleted.toggle() } label: { Label(item.isCompleted ? "Uncheck" : "Check", systemImage: "checkmark") }.tint(tint)
        }
        .contextMenu {
            ForEach(0..<3, id: \.self) { i in
                Button { item.priority = i } label: { Label(priorities[i], systemImage: priorityIcons[i]) }
            }
            Divider()
            Button(role: .destructive) { modelContext.delete(item) } label: { Label("Delete", systemImage: "trash") }
        }
    }

    private func add() {
        let t = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        let cat = selectedCategory == "All" ? "General" : selectedCategory
        modelContext.insert(ChecklistItem(title: t, priority: selectedPriority, category: cat))
        newTitle = ""
    }
}
