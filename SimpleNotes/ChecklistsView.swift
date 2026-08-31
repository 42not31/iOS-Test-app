import SwiftUI
import SwiftData

struct ChecklistsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChecklistItem.createdAt, order: .reverse) private var items: [ChecklistItem]

    @State private var newItemTitle = ""
    @State private var selectedCategory = "All"
    @State private var selectedPriority = 0
    @State private var searchText = ""
    @State private var showingPriorityPicker = false

    private var categories: [String] {
        var cats = Set(items.map { $0.category })
        cats.insert("General")
        return ["All"] + cats.sorted()
    }

    private var filteredItems: [ChecklistItem] {
        items.filter { item in
            let matchesSearch = searchText.isEmpty || item.title.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "All" || item.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    private var completedCount: Int { items.filter { $0.isCompleted }.count }
    private var progress: Double { items.isEmpty ? 0 : Double(completedCount) / Double(items.count) }

    private let priorityColors: [Color] = [Color(hex: "00D2FF"), Color(hex: "FFB703"), Color(hex: "FF477E")]
    private let priorityLabels = ["Normal", "High", "Urgent"]
    private let priorityIcons = ["circle", "exclamationmark.circle", "flame.fill"]

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidAmbientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Checklists")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                Text("\(completedCount)/\(items.count) completed")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            ProgressRing(progress: progress, size: 56, tint: Color(hex: "00D2FF"))
                                .overlay {
                                    Text("\(Int(progress * 100))%")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                        // Stats row
                        HStack(spacing: 12) {
                            statCard(title: "Remaining", value: "\(items.count - completedCount)", icon: "circle", tint: Color(hex: "00D2FF"))
                            statCard(title: "Done", value: "\(completedCount)", icon: "checkmark.circle.fill", tint: Color(hex: "4CAF50"))
                            statCard(title: "Total", value: "\(items.count)", icon: "list.bullet", tint: Color(hex: "9D4EDD"))
                        }
                        .padding(.horizontal, 16)

                        // Quick add bar
                        HStack(spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(priorityColors[selectedPriority])
                                TextField("Add a task...", text: $newItemTitle)
                                    .font(.system(size: 15, design: .rounded))
                                    .onSubmit { addItem() }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .liquidGlass(cornerRadius: 14, opacity: 0.7)

                            Menu {
                                ForEach(0..<3, id: \.self) { idx in
                                    Button {
                                        selectedPriority = idx
                                    } label: {
                                        Label(priorityLabels[idx], systemImage: priorityIcons[idx])
                                    }
                                }
                            } label: {
                                Image(systemName: priorityIcons[selectedPriority])
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(priorityColors[selectedPriority])
                                    .padding(10)
                                    .liquidGlass(cornerRadius: 12, tint: priorityColors[selectedPriority])
                            }

                            Button(action: addItem) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(newItemTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.secondary.opacity(0.4) : Color(hex: "00D2FF"))
                            }
                            .disabled(newItemTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding(.horizontal, 16)

                        GlassSearchBar(text: $searchText, placeholder: "Search tasks...")
                            .padding(.horizontal, 16)

                        // Category pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categories, id: \.self) { cat in
                                    let isSelected = (selectedCategory == cat)
                                    Button {
                                        withAnimation(.spring(response: 0.3)) { selectedCategory = cat }
                                    } label: {
                                        Text(cat)
                                            .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .rounded))
                                            .padding(.horizontal, 12).padding(.vertical, 7)
                                            .background {
                                                if isSelected {
                                                    Capsule().fill(LinearGradient(colors: [Color(hex: "00D2FF"), Color(hex: "3A86FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                } else {
                                                    Capsule().fill(.ultraThinMaterial).strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8)
                                                }
                                            }
                                            .foregroundStyle(isSelected ? .white : .primary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Checklist items
                        if filteredItems.isEmpty {
                            if items.isEmpty {
                                emptyChecklistView
                                    .padding(.horizontal, 16)
                                    .padding(.top, 20)
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass").font(.system(size: 28)).foregroundStyle(.secondary)
                                    Text("No tasks match your filter").foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 30)
                            }
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(filteredItems) { item in
                                    checklistRow(item: item)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 6)
                }
            }
        }
    }

    private func statCard(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundStyle(tint)
            Text(value).font(.system(size: 20, weight: .bold, design: .rounded))
            Text(title).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .liquidGlass(cornerRadius: 16, tint: tint, opacity: 0.6)
    }

    private func checklistRow(item: ChecklistItem) -> some View {
        let tint = priorityColors[min(item.priority, 2)]
        return HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                    item.isCompleted.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(item.isCompleted ? tint : Color.secondary.opacity(0.4), lineWidth: 2)
                        .frame(width: 26, height: 26)
                        .background { Circle().fill(item.isCompleted ? tint : Color.clear).frame(width: 26, height: 26) }
                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .strikethrough(item.isCompleted)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    GlassBadge(title: priorityLabels[min(item.priority, 2)], icon: priorityIcons[min(item.priority, 2)], tint: tint)
                    if !item.category.isEmpty && item.category != "General" {
                        GlassBadge(title: item.category, icon: "tag.fill")
                    }
                    if let due = item.dueDate {
                        GlassBadge(title: due.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                    }
                }
            }
            Spacer()
            Menu {
                ForEach(0..<3, id: \.self) { idx in
                    Button { item.priority = idx } label: { Label(priorityLabels[idx], systemImage: priorityIcons[idx]) }
                }
                Divider()
                Button(role: .destructive) {
                    withAnimation { modelContext.delete(item) }
                } label: { Label("Delete", systemImage: "trash") }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
        .padding(12)
        .liquidGlass(cornerRadius: 16, tint: item.isCompleted ? nil : tint.opacity(0.08) as Color? , opacity: 0.7)
        .opacity(item.isCompleted ? 0.75 : 1)
    }

    private var emptyChecklistView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(LinearGradient(colors: [Color(hex: "00D2FF").opacity(0.25), Color(hex: "9D4EDD").opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 90, height: 90).blur(radius: 8)
                Image(systemName: "checklist").font(.system(size: 36, weight: .light)).foregroundStyle(Color(hex: "00D2FF"))
            }
            Text("No Tasks Yet").font(.system(size: 19, weight: .bold, design: .rounded))
            Text("Add your first task above to start tracking.").font(.system(size: 14)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 32)
        .liquidGlass(cornerRadius: 24, opacity: 0.5)
    }

    private func addItem() {
        let trimmed = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = ChecklistItem(title: trimmed, priority: selectedPriority, category: selectedCategory == "All" ? "General" : selectedCategory)
        modelContext.insert(item)
        newItemTitle = ""
    }
}
