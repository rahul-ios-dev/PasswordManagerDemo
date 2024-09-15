//
//  ReusableComponents.swift
//  PasswordManagerDemo
//
//  Created by Rahul Acharya on 15/09/24.
//

import SwiftUI

// MARK: - Reusable Components
struct PrimaryButton: View {
    let title: String
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity) // Make the button take maximum available width
                .foregroundColor(.white)    // Set text color
                .padding()
                .background(Capsule().fill(backgroundColor))
        }
    }
}

struct HeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
    }
}

struct DividerView: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .frame(height: 1)
    }
}

struct AccountCell: View {
    let account: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.white)
                .frame(height: 65)
                .shadow(color: Color.gray.opacity(0.1), radius: 1)
                .padding()
                .padding(.vertical, -10)
                .overlay {
                    HStack {
                        Text(account)
                            .font(.headline)
                            .fontWeight(.regular)
                            .padding(.leading, 30)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Text("*********")
                            .font(.caption)
                            .fontWeight(.regular)
                            .foregroundStyle(.gray)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 30)
                    }
                }
        }
        .buttonStyle(PlainButtonStyle()) // Remove button animation styling
    }
}

struct CapsuleView: View {
    var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(maxWidth: .infinity, maxHeight: 5)
            .overlay(
                Capsule()
                    .fill(.gray.opacity(0.9))
                    .frame(width: 50, height: 5)
            )
    }
}

struct InfoSectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
            Text(content)
                .font(.headline)
                .foregroundStyle(.black)
        }
    }
}


struct AddPasswordButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(maxWidth: .infinity, maxHeight: 100)
            .overlay(alignment: .topTrailing) {
                Button(action: onTap) {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                        .padding(.horizontal, 30)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                        )
                }
            }
    }
}
