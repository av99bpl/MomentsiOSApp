// AddEditScreen.swift
// Moments

import SwiftUI
import SwiftData
import WidgetKit

struct AddEditScreen: View {
    let existingID: PersistentIdentifier?
    let onNavigate: (NavDest) -> Void

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allEntries: [MomentEntry]

    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var recurrence: Recurrence = .none
    @State private var didInit = false
    @FocusState private var titleFocused: Bool

    var existingEntry: MomentEntry? {
        guard let id = existingID else { return nil }
        return allEntries.first { $0.persistentModelID == id }
    }

    var isEdit: Bool { existingID != nil }
    var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Color.clear.frame(height: MSpace.statusBar)

                // Card — same style as hero card
                VStack(alignment: .leading, spacing: 0) {
                    Text(isEdit ? "Editing" : "Add Moment")
                        .font(.mSans(MType.navItem, weight: .semibold))
                        .foregroundStyle(Color.mInk)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 16)
                        .overlay(alignment: .bottom) { Color.mHairline.frame(height: 1) }

                    VStack(alignment: .leading, spacing: 0) {
                        titleField
                        dateField
                        recurrenceField
                    }
                    .padding(.horizontal, MSpace.sheetPadH)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
                .frame(maxWidth: .infinity)
                .paperRaisedBG()
                .clipShape(RoundedRectangle(cornerRadius: MSpace.heroRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: MSpace.heroRadius)
                        .stroke(Color.mHairline, lineWidth: 1)
                )
                .padding(.horizontal, MSpace.heroMargin)
                .padding(.top, 16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            // Buttons float above the keyboard via safeAreaInset
            HStack(spacing: 16) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.mInkSoft)
                        .frame(width: 46, height: 46)
                        .overlay(Circle().stroke(Color.mHairline, lineWidth: 1))
                }

                Button { performSave() } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(canSave ? Color.mInk : Color.mInkSoft)
                        .frame(width: 46, height: 46)
                        .overlay(Circle().stroke(canSave ? Color.mInk : Color.mHairline, lineWidth: 1))
                }
                .disabled(!canSave)
            }
            .padding(.top, 16)
            .padding(.bottom, MSpace.sheetPadBottom)
            .frame(maxWidth: .infinity)
            .background(Color.mPaper.opacity(0.001)) // keeps the inset area stable
        }
        .paperBG()
        .onAppear {
            initFormIfReady()
            if !isEdit { titleFocused = true }
        }
        .onChange(of: existingEntry?.id) { initFormIfReady() }
    }

    // MARK: - Fields

    var titleField: some View {
        VStack(alignment: .leading, spacing: 4) {
            fieldLabel("Title")
            TextField("", text: $title)
                .font(.mSerif(24))
                .foregroundStyle(Color.mInk)
                .tint(Color.mInk)
                .focused($titleFocused)
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

    // MARK: - Helpers

    func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.mSans(MType.fieldLabel, weight: .semibold))
            .foregroundStyle(Color.mInkSoft)
            .tracking(1)
            .textCase(.uppercase)
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

    func initFormIfReady() {
        guard !didInit, let e = existingEntry else { return }
        didInit = true
        title = e.title
        date = e.date
        recurrence = e.recurrence
    }

    // MARK: - Actions

    func performSave() {
        guard canSave else { return }
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        if let entry = existingEntry {
            entry.title = trimmed
            entry.date = date
            entry.recurrence = recurrence
        } else {
            let newEntry = MomentEntry(title: trimmed, date: date, recurrence: recurrence)
            modelContext.insert(newEntry)
        }
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}
