struct ListItemView: View {
    let title: String
    let subtitle: String
    var url: String

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary)
                .frame(width: .infinity, height: CGFloat(80))
            HStack {
                image(from: URL(string: url))
                    .foregroundColor(.green)
                    .frame(width: CGFloat(72), height: CGFloat(72))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                VStack(alignment: .leading) {
                    Text(title)
                    Text(subtitle)
                }
            }.padding(4)
        }.padding(16)
    }

    private func image(from url: URL?) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ProgressView()
        }
    }
}