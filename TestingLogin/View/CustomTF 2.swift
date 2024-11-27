//
//  CustomTF.swift
//  Auth
//
//  Created by Meriem Abid on 6/10/2024.
//

import SwiftUI

struct CustomTF: View {
    
    var sfIcon: String // pour l'icone
    var iconTint: Color = .gray // pour la couleur de l'icone
    var hint: String //pour le placeholder
    
    var isPassword: Bool = false
    
    @Binding var value: String
    
    @State private var showPassword: Bool = false
    var body: some View {
        HStack(alignment: .top,spacing: 8, content: {
            Image(systemName: sfIcon)
                .foregroundStyle(iconTint)
            // width pour aligner les TF equally
                    .frame(width: 30)
                    .offset(y: 2)
            
            VStack(alignment: .leading,spacing: 8, content: {
                if isPassword{
                    Group{
                        if showPassword{
                            // un textfield normal
                            TextField(hint,text:$value)
                        } else {
                            // un textfield special password
                            SecureField(hint,text:$value)
                        }
                    }
                } else {
                    TextField(hint, text:$value)
                }
                
                Divider()
            })
            .overlay(alignment: .trailing){
                
                if isPassword {
                    Button(action: {
                        withAnimation{
                            showPassword.toggle()
                        }
                                      
                    }, label: {
                        Image(systemName: showPassword ? "eye" : "eye.slash")
                            .foregroundStyle(.gray)
                            .padding(10)
                            .contentShape(.rect)
                    })
                }
                
            }
        })
    }
}


