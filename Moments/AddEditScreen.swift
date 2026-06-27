import SwiftUI
import SwiftData

private let iconOptions = ["🎂", "💍", "🎉", "✈️", "🏠", "💼", "🩺", "🌱"]

struct AddEditScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    // nil = add mode, non-nil = edit mode
    let existingEntry: MomentEntry?

    @State private var title: String
    @State private var date: Date
    @State private var direction: Direction
    @State private var recurrence: Recurrence
    @State private var accentID: String
    @State private var icon: String?
    @State private var showConfirmDelete = false

    var isEdit: Bool { existingEntry != nil }

    init(existingEntry: MomentEntry?) {
        self.existingEntry = existingEntry
        _title      = State(initialValue: existingEntry?.title ?? "")
        _date       = State(initialValue: existingEntry?.date ?? Date())
        _direction  = State(initialValue: existingEntry?.direction ?? .down)
        _recurrence = State(initialValue: existingEntry?.recurrence ?? .none)
        _accentID   = State(initialValue: existingEntry?.accentID ?? "clay")
        _icon       = State(initialValue: existingEntry?.icon)
    }

    var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            Color.mPaper.ignoresSafeArea()

            VStack(spacing: 0) {
                // Status bar spacer
                Color.clear.frame(height: MSpacing.statusBar)

                // Nav bar
                navBar

                // Form content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        titleField
                        dateField
                        directionField
                        recurrenceField
                        customizationField

                        if isEdit {
                            deleteButton
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }

            // Confirm delete overlay
            if showConfirmDelete, let entry = existingEntry {
                ConfirmDeleteSheet(
                    title: entry.title,
                    onDelete: {
                        performDelete(entry)
                        showConfirmDelete = false
                    },
                    onCancel: { showConfirmDelete = false }
                )
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showConfirmDelete)
    }

    // MARK: - Nav bar

    var navBar: some View {
        HStack {
            Button("Cancel") {
                appState.showAddEdit = false
                appState.editingEntry = nil
            }
            .font(.mSans(16))
            .foregroundStyle(Color.mInk)
            .padding(8)

            Spacer()

            Text(isEdit ? "Edit Date" : "New Date")
                .font(.mSans(16, weight: .semibold))
                .foregroundStyle(Color.mInk)

            Spacer()

            Button("Save") {
                performSave()
            }
            .font(.mSans(16, weight: .bold))
            .foregroundStyle(canSave ? Color.mInk : Color.mHairline)
            .padding(8)
            .disabled(!canSave)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    // MARK: - Fields

    var titleField: some View {
        VStack(alignment: .leading, spacing: 4) {
            fieldLabel("Title")
            TextField("Mom's Birthday", text: $title)
                .font(.mSerif(24))
                .foregroundStyle(Color.mInk)
                .tint(Color.mInk)
                .padding(.vertical, 8)
                .padding(.bottom, 6)
                .overlay(alignment: .bottom) {
                    Color.mHairline.frame(height: 1)
                }
        }
        .padding(.bottom, MSpacing.formFieldGap)
    }

    var dateField: some View {
        VStack(alignment: .leading, spacing: 4) {
            fieldLabel("Date")
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(Color.mInk)
                .padding(.vertical, 4)
                .padding(.bottom, 6)
                .overlay(alignment: .bottom) {
                    Color.mHairline.frame(height: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, MSpacing.formFieldGap)
    }

    var directionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("This date is")
            HStack(spacing: 10) {
                segButton("Upcoming", active: direction == .down) { direction = .down }
                segButton("In the past", active: direction == .up) { direction = .up }
            }
        }
        .padding(.bottom, MSpacing.formFieldGap)
    }

    var recurrenceField: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Repeats")
            FlowLayout(spacing: MSpacing.chipGap) {
                ForEach(Recurrence.allCases, id: \.self) { r in
                    chipButton(r.chipLabel, active: recurrence == r) { recurrence = r }
                }
            }
        }
        .padding(.bottom, MSpacing.formFieldGap)
    }

    var customizationField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                fieldLabel("Color & Icon")
                if !appState.isPremium {
                    Image(systemName: "lock")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.mInkSoft)
                        .offset(y: -8)
                }
            }

            // Color swatches
            HStack(spacing: 10) {
                ForEach(AccentColor.all) { accent in
                    Button {
                        accentID = accent.id
                    } label: {
                        Circle()
                            .fill(accent.color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.mPaper, lineWidth: 2)
                                    .padding(1)
                                    .opacity(accentID == accent.id ? 1 : 0)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.mInk, lineWidth: accentID == accent.id ? 2 : 0)
                            )
                    }
                    .disabled(!appState.isPremium)
                }
            }
            .opacity(appState.isPremium ? 1 : 0.35)

            // Emoji icons
            let columns = Array(repeating: GridItem(.fixed(38), spacing: 8), count: 8)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(iconOptions, id: \.self) { emoji in
                    Button {
                        icon = (icon == emoji) ? nil : emoji
                    } label: {
                        Text(emoji)
                            .font(.system(size: 17))
                            .frame(width: 38, height: 38)
                            .background(icon == emoji ? Color.mPaperRaised : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(icon == emoji ? Color.mInk : Color.mHairline, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!appState.isPremium)
                }
            }
            .opacity(appState.isPremium ? 1 : 0.35)
        }
        // Tap through to paywall when locked
        .overlay {
            if !appState.isPremium {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        appState.paywallReturnToAdd = true
                        appState.showPaywall = true
                    }
            }
        }
        .padding(.bottom, MSpacing.formFieldGap)
    }

    var deleteButton: some View {
        Button {
            showConfirmDelete = true
        } label: {
            Text("Delete Date")
                .font(.mSans(15, weight: .semibold))
                .foregroundStyle(Color.mDestructive)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    // MARK: - Helpers

    func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.mSans(12, weight: .semibold))
            .foregroundStyle(Color.mInkSoft)
            .tracking(1)
            .textCase(.uppercase)
    }

    func segButton(_ label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.mSans(14, weight: .semibold))
                .foregroundStyle(active ? Color.mPaper : Color.mInk)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(active ? Color.mInk : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(active ? Color.mInk : Color.mHairline, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    func chipButton(_ label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if active {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                }
                Text(label)
                    .font(.mSans(MTypography.chip, weight: .semibold))
            }
            .foregroundStyle(active ? Color.mPaper : Color.mInk)
            .padding(.vertical, 9)
            .padding(.horizontal, 16)
            .background(active ? Color.mInk : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(active ? Color.mInk : Color.mHairline, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    // MARK: - Actions

    func performSave() {
        guard canSave else { return }
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        if let entry = existingEntry {
            entry.title = trimmed
            entry.date = date
            entry.direction = direction
            entry.recurrence = recurrence
            entry.accentID = accentID
            entry.icon = icon
            scheduleReminder(for: entry)
        } else {
            let newEntry = MomentEntry(
                title: trimmed,
                date: date,
                recurrence: recurrence,
                direction: direction,
                accentID: accentID,
                icon: icon
            )
            modelContext.insert(newEntry)
        }
        appState.showAddEdit = false
        appState.editingEntry = nil
    }

    func performDelete(_ entry: MomentEntry) {
        if appState.pinnedID == entry.id { appState.clearPin() }
        let entryTitle = entry.title
        // Close detail if viewing this entry
        if appState.selectedEntry?.id == entry.id {
            appState.showDetail = false
            appState.selectedEntry = nil
        }
        modelContext.delete(entry)
        appState.showAddEdit = false
        appState.editingEntry = nil
        appState.showToast("Deleted \"\(entryTitle)\"")
    }
}
