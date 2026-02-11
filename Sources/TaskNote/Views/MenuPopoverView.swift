import SwiftUI

enum PopoverTab: String, CaseIterable {
    case tasks = "Tasks"
    case today = "Today"
    case notes = "Notes"
}

struct MenuPopoverView: View {
    @ObservedObject var taskStore: TaskStore
    @ObservedObject var noteStore: NoteStore
    @ObservedObject var settingsStore: SettingsStore
    let onDirectoryChanged: (URL) -> Void

    @State private var selectedTab: PopoverTab = .tasks
    @State private var inputText = ""
    @State private var showSettings = false
    @State private var showCompleted = false
    @State private var showTodayCompleted = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if showSettings {
                settingsContent
            } else {
                mainContent
            }
        }
        .frame(width: 360, height: 480)
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        inputBar

        Divider()

        tabBar

        Divider()

        switch selectedTab {
        case .tasks:
            taskList
        case .today:
            todayList
        case .notes:
            noteList
        }

        Divider()

        footer
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 8) {
            Image(systemName: inputBarIcon)
                .foregroundStyle(.secondary)

            TextField(
                inputBarPlaceholder,
                text: $inputText
            )
            .textFieldStyle(.plain)
            .focused($isInputFocused)
            .onSubmit(submitInput)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var inputBarIcon: String {
        switch selectedTab {
        case .tasks: return "plus.circle"
        case .today: return "sun.max"
        case .notes: return "note.text.badge.plus"
        }
    }

    private var inputBarPlaceholder: String {
        switch selectedTab {
        case .tasks: return "Add a task..."
        case .today: return "Add a task for today..."
        case .notes: return "Add a note..."
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(PopoverTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 13, weight: selectedTab == tab ? .semibold : .regular))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(selectedTab == tab ? Color.accentColor.opacity(0.1) : .clear)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Task List

    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                let active = taskStore.tasks.filter { !$0.isCompleted }
                let completed = taskStore.tasks.filter { $0.isCompleted }

                if active.isEmpty && completed.isEmpty {
                    emptyState(
                        icon: "checkmark.circle",
                        message: "No tasks yet",
                        hint: "Type above and press Enter"
                    )
                } else {
                    ForEach(active) { task in
                        taskRow(task)
                    }

                    if !completed.isEmpty {
                        completedSection(completed, isExpanded: $showCompleted)
                    }
                }
            }
        }
    }

    // MARK: - Today List

    private var todayList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                let todayActive = taskStore.tasks.filter { $0.isToday && !$0.isCompleted }
                let todayCompleted = taskStore.tasks.filter { $0.isToday && $0.isCompleted }

                if todayActive.isEmpty && todayCompleted.isEmpty {
                    emptyState(
                        icon: "sun.max",
                        message: "No tasks for today",
                        hint: "Right-click a task to add it, or type above"
                    )
                } else {
                    ForEach(todayActive) { task in
                        taskRow(task)
                    }

                    if !todayCompleted.isEmpty {
                        completedSection(todayCompleted, isExpanded: $showTodayCompleted)
                    }
                }
            }
        }
    }

    // MARK: - Task Row Helper

    private func taskRow(_ task: TaskItem) -> some View {
        TaskRowView(
            task: task,
            onToggle: { taskStore.toggleTask(task) },
            onUpdate: { text in taskStore.updateTask(task, text: text) },
            onTodayToggle: { taskStore.toggleToday(task) },
            onDelete: { taskStore.deleteTask(task) }
        )
    }

    // MARK: - Completed Section

    private func completedSection(_ tasks: [TaskItem], isExpanded: Binding<Bool>) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10))
                    Text("Completed (\(tasks.count))")
                        .font(.system(size: 12))
                    Spacer()
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded.wrappedValue {
                ForEach(tasks) { task in
                    taskRow(task)
                }
            }
        }
    }

    // MARK: - Note List

    private var noteList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if noteStore.notes.isEmpty {
                    emptyState(
                        icon: "note.text",
                        message: "No notes yet",
                        hint: "Type above and press Enter"
                    )
                } else {
                    ForEach(noteStore.notes) { note in
                        NoteRowView(
                            note: note,
                            onUpdate: { content in noteStore.updateNote(note, content: content) },
                            onDelete: { noteStore.deleteNote(note) }
                        )
                        Divider()
                            .padding(.horizontal, 8)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private func emptyState(icon: String, message: String, hint: String) -> some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(.quaternary)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            Text(hint)
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Text(footerText)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var footerText: String {
        switch selectedTab {
        case .tasks:
            let count = taskStore.tasks.filter { !$0.isCompleted }.count
            return "\(count) active"
        case .today:
            let count = taskStore.tasks.filter { $0.isToday && !$0.isCompleted }.count
            return "\(count) today"
        case .notes:
            return "\(noteStore.notes.count) notes"
        }
    }

    // MARK: - Settings

    private var settingsContent: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    showSettings = false
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12))
                        Text("Back")
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            SettingsView(
                settingsStore: settingsStore,
                onDirectoryChanged: onDirectoryChanged
            )
        }
    }

    // MARK: - Actions

    private func submitInput() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        switch selectedTab {
        case .tasks:
            taskStore.addTask(trimmed)
        case .today:
            taskStore.addTask(trimmed, isToday: true)
        case .notes:
            noteStore.addNote(trimmed)
        }

        inputText = ""
    }
}
