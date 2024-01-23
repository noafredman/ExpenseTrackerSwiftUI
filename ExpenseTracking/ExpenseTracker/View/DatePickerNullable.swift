import SwiftUI

struct DatePickerNullable: View {
    @State private var text = "Select a date"
    @State private var foregroundColor = Color(.gray.opacity(0.5))
    @State private var selectedDate: Date = Date()
    @Binding var date: Date?
    
    init(selection: Binding<Date?>){
        self._date = selection
    }
    
    var body: some View {
        VStack {
            HStack {
                if date != nil {
                    Button {
                        setDate(nil)
                    } label: {
                        Images.xmark
                    }
                    .frame(width: 44, alignment: .leading)
                    .foregroundStyle(Color(.label))
                    .onAppear() {
                        setDate(date)
                    }
                }
                
                Text(date == nil ? "Select a date" : text)
                    .font(HelveticaFontsEnum.regular(size: 18).font())
                    .foregroundStyle(date == nil ? Color(.gray.opacity(0.5)) : foregroundColor)
                    .padding(.trailing, 40)
                    .overlay{ // Place the DatePicker in the overlay extension
                        DatePicker(
                            "",
                            selection: $selectedDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        .blendMode(.destinationOver)
                        // use this extension to keep the clickable functionality credit: https://stackoverflow.com/questions/65797437/how-to-make-a-button-or-any-other-element-show-swiftuis-datepicker-popup-on-t
                        .onChange(of: selectedDate) {
                            setDate(selectedDate)
                        }
                        .onTapGesture(count: 99, perform: {
                            // fixes issue of date picker not opening on iOS 17.1 real device - overrides tap gesture to fix the bug
                            // https://stackoverflow.com/questions/77373659/swiftui-datepicker-issue-ios-17-1
                        })
                        .simultaneousGesture(TapGesture().onEnded({
                            datePickerTapped(date)
                        }))
                    }
                
                Spacer()
            }
        }
    }
    
    private func setDate(_ dateVal: Date?) {
        if let dateVal {
            date = dateVal
            text = dateVal.toString()
            foregroundColor = Color(.label)
        } else {
            date = nil
            text = "Select a date"
            foregroundColor = Color(.gray.opacity(0.5))
        }
    }
    
    private func datePickerTapped(_ dateVal: Date?) {
        if let dateVal {
            selectedDate = dateVal
            date = dateVal
            text = dateVal.toString()
            foregroundColor = Color(.label)
        } else {
            date = selectedDate
            text = selectedDate.toString()
            foregroundColor = Color(.label)
        }
    }
}

#Preview {
    DatePickerNullable(selection: .constant(Date()))
}
