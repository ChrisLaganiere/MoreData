import Foundation

extension Statement {

    /// Thumbnail image to use in list view
    var thumbnailFileName: String {
        by?.avatarFileName ?? ""
    }

    /// Formatted content for display to user
    func formattedContent(searchQuery: String? = nil) -> String {
        var content = self.content ?? ""

        if let searchQuery {
            content = content.replacingOccurrences(of: searchQuery, with: "**\(searchQuery)**")
        }

        return content
    }
}
