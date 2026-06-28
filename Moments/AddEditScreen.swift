// AddEditScreen.swift
// Moments
//
// Pushed onto NavigationStack. nil existingID = add mode.

import SwiftUI
import SwiftData

struct AddEditScreen: View {
    let existingID: PersistentIdentifier?
    let onNavigate: (NavDest) -> Void
    let onDeleteComplete: () -> Void

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allEntries: [MomentEntry]

    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var direction: Direction = .down
    @State private var recurrence: Recurrence = .none
    @State private var showConfirmDelete = false
    @State private var didInit = false

    var existingEntry: MomentEntry? {
        guard let id = existingID else { return nil }
        return allEntries.first { $0.persistentModelID == id }
    }

    var isEdit: Bool { existingID != nil }
    var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Color.clear.frame(height: MSpace.statusBar)
                navBar

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        titleField
                        dateField
                        directionField
                        recurrenceField

                        if isEdit {
                            deleteButton
                        }
                    }
                    .padding(.horizontal, MSpace.sheetPadH)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }

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
                .animation(.easeInOut(duration: 0.2), value: showConfirmDelete)
            }
        }
        .paperBG()
        .onAppear {
            guard !didInit else { return }
            didInit = true
            if let e = existingEntry {
                title = e.title
                date = e.date
                direction = e.direction
                recurrence = e.recurrence
            }
        }
    }

    // MARK: - Nav bar

    var navBar: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .font(.mSans(MType.navItem))
                .foregroundStyle(Color.mInk)
                .padding(8)

            Spacer()

            Text(isEdit ? "Edit Date" : "New Date")
                .font(.mSans(MType.navItem, weight: .semibold))
                .foregroundStyle(Color.mInk)

            Spacer()

            Button("Save") { performSave() }
                .font(.mSans(MType.navItem, weight: .bold))
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
                .overlay(alignment: .bottom) { Color.mHairline.frame(height: 1) }
        }
        .padding(.bottom, MSpace.formFieldGap)
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
                .overlay(alignment: .bottom) { Color.mHairline.frame(height: 1) }
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, MSpace.formFieldGap)
    }

    var directionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("This date is")
            HStack(spacing: 10) {
                segButton("Upcoming", active: direction == .down) { direction = .down }
                segButton("In the past", active: direction == .up) { direction = .up }
            }
        }
        .padding(.bottom, MSpace.formFieldGap)
    }

    var recurrenceField: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Repeats")
            FlowLayout(spacing: MSpace.chipGap) {
                ForEach(Recurrence.allCases, id: \.self) { r in
                    chipButton(r.chipLabel, active: recurrence == r) { recurrence = r }
                }
            }
        }
        .padding(.bottom, MSpace.formFieldGap)
    }

    var deleteButton: some View {
        Button { showConfirmDelete = true } label: {
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
            .font(.mSans(MType.fieldLabel, weight: .semibold))
            .foregroundStyle(Color.mInkSoft)
            .tracking(1)
            .textCase(.uppercase)
    }

    func segButton(_ label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.mSans(MType.segButton, weight: .semibold))
                .foregroundStyle(active ? Color.mPaper : Color.mInk)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MSpace.segV)
                .background(active ? Color.mInk : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: MSpace.segRadius)
                        .stroke(active ? Color.mInk : Color.mHairline, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: MSpace.segRadius))
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
                    .font(.mSans(MType.chip, weight: .semibold))
            }
            .foregroundStyle(active ? Color.mPaper : Color.mInk)
            .padding(.vertical, MSpace.chipV)
            .padding(.horizontal, MSpace.chipH)
            .background(active ? Color.mInk : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: MSpace.chipRadius)
                    .stroke(active ? Color.mInk : Color.mHairline, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: MSpace.chipRadius))
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
        } else {
            let newEntry = MomentEntry(
                title: trimmed,
                date: date,
                recurrence: recurrence,
                direction: direction
            )
            modelContext.insert(newEntry)
        }
        dismiss()
    }

    func performDelete(_ entry: MomentEntry) {
        if appState.pinnedEntryID == entry.id {
            appState.unpin(entry: entry)
        }
        let title = entry.title
        modelContext.delete(entry)
        appState.showToast("Deleted \"\(title)\"")
        onDeleteComplete()
    }
}
