//
//  ImageView.swift
//  Not-Spotify
//
//  Created by Naten on 03.09.24.
//

import SwiftUI

struct ImageView: View {
    let url: URL?
    var systemName: String? = nil

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            if let systemName {
                Image(systemName: systemName)
                    .foregroundColor(.green)
                    .font(.system(size: Constants.magicNumber))
            } else {
                ProgressView()
            }
        }
    }
}
