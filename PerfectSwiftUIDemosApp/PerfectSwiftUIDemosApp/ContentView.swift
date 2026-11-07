
import SwiftUI
import LinkPresentation
import SafariServices

// MARK: - App Language

enum AppLanguage: String, CaseIterable, Identifiable {

    case zhHans = "zh-Hans"
    case zhHK = "zh-Hant-HK"
    case zhTW = "zh-Hant-TW"
    case en = "en"
    case th = "th"
    case ja = "ja"
    case vi = "vi"
    case fr = "fr"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .zhHans: "简体中文"
        case .zhHK: "繁體中文（香港）"
        case .zhTW: "繁體中文（台灣）"
        case .en: "English"
        case .th: "ไทย"
        case .ja: "日本語"
        case .vi: "Tiếng Việt"
        case .fr: "Français"
        }
    }
}

// MARK: - Localized Text

typealias LocalizedText = [AppLanguage: String]

extension Dictionary where Key == AppLanguage, Value == String {

    func localized(for language: AppLanguage) -> String {
        self[language]
        ?? self[.zhHans]
        ?? self[.en]
        ?? ""
    }
}

// MARK: - Animation Demo Model

struct AnimationDemo: Identifiable {

    let id = UUID()

    let name: String
    let createdAt: Date

    let description: LocalizedText

    // YouTube
    let url: URL?

    // GitHub
    let githubURL: URL?

    // Whether additional Assets are required
    let requiresAssets: Bool

    // Common translated text
    let tutorialText: LocalizedText

    // SwiftUI destination
    let destination: AnyView
}

// MARK: - Animation Demo Data

extension AnimationDemo {

    // Catalog dates use Gregorian days in UTC so device settings cannot shift them.
    private static func creationDate(year: Int, month: Int, day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else {
            preconditionFailure("Invalid demo creation date")
        }
        return date
    }

    static let all: [AnimationDemo] = {

        // MARK: Common Tutorial Text

        let tutorialText: LocalizedText = [
            .zhHans: "打开视频教程",
            .zhHK: "開啟影片教學",
            .zhTW: "開啟教學影片",
            .en: "Open Video Tutorial",
            .th: "เปิดวิดีโอสอน",
            .ja: "解説動画を開く",
            .vi: "Mở video hướng dẫn",
            .fr: "Ouvrir le tutoriel vidéo"
        ]

        // MARK: All Animations

        return [

            // MARK: 01 - Theme Switcher

            AnimationDemo(
                name: "SwiftUI Animated App Theme Switcher - Xcode 27",
                createdAt: creationDate(year: 2026, month: 11, day: 7),

                description: [
                    .zhHans: "切换深色模式",
                    .zhHK: "切換深色模式",
                    .zhTW: "切換深色模式",
                    .en: "Switch to Dark Mode",
                    .th: "เปลี่ยนเป็นโหมดมืด",
                    .ja: "ダークモードに切り替える",
                    .vi: "Chuyển sang chế độ tối",
                    .fr: "Passer en mode sombre"
                ],

                url: URL(
                    string: "https://www.youtube.com/watch?v=_Sw-OBZGO6k&t=116s"
                ),

                githubURL: URL(
                    string: "https://github.com/haveagoodday-github/Perfect-SwiftUI-Demos/blob/main/PerfectSwiftUIDemosApp/PerfectSwiftUIDemosApp/Demos/AnimatedAppThemeSwitcherXcode27.swift"
                ),

                // 按实际资源依赖修改
                requiresAssets: true,

                tutorialText: tutorialText,

                destination: AnyView(
                    AnimatedAppThemeSwitcherXcode27()
                )
            ),

            // MARK: 02 - Chat Bubble

            AnimationDemo(
                name: "Chat Bubble TextField Transition Using SwiftUI | iOS 27 | Xcode 27",
                createdAt: creationDate(year: 2026, month: 11, day: 7),

                description: [
                    .zhHans: "顺滑气泡转到对话框",
                    .zhHK: "聊天氣泡流暢轉換為對話框",
                    .zhTW: "聊天泡泡流暢切換至對話框",
                    .en: "Smooth Chat Bubble to Text Field Transition",
                    .th: "เปลี่ยนบับเบิลแชตเป็นช่องข้อความอย่างลื่นไหล",
                    .ja: "チャットバブルから入力欄への滑らかな切り替え",
                    .vi: "Chuyển mượt mà từ bong bóng chat sang ô nhập liệu",
                    .fr: "Transition fluide de la bulle vers le champ de saisie"
                ],

                url: URL(
                    string: "https://www.youtube.com/watch?v=oethb4xWhY8&t=8s"
                ),

                githubURL: URL(
                    string: "https://github.com/haveagoodday-github/Perfect-SwiftUI-Demos/blob/main/PerfectSwiftUIDemosApp/PerfectSwiftUIDemosApp/Demos/ChatBubbleTextFieldTransitionUsingSwiftUI.swift"
                ),

                // 按实际资源依赖修改
                requiresAssets: false,

                tutorialText: tutorialText,

                destination: AnyView(
                    ChatBubbleTextFieldTransitionUsingSwiftUI()
                )
            )
        ]
    }()
}

// MARK: - Content View

struct ContentView: View {

    private let demos = AnimationDemo.all

    @AppStorage("appLanguage")
    private var languageCode = AppLanguage.zhHans.rawValue

    @State private var selectedWebsite: Website?
    @State private var searchText = ""
    @State private var newestFirst = true

    private var filteredDemos: [AnimationDemo] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return demos.filter { demo in
            query.isEmpty
                || demo.name.localizedStandardContains(query)
                || demo.description.values.contains { $0.localizedStandardContains(query) }
        }
        .sorted { lhs, rhs in
            // Keep the catalog order when dates match.
            guard lhs.createdAt != rhs.createdAt else { return false }
            return newestFirst ? lhs.createdAt > rhs.createdAt : lhs.createdAt < rhs.createdAt
        }
    }

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .zhHans
    }

    var body: some View {
        let visibleDemos = filteredDemos

        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {

                    ForEach(visibleDemos) { demo in
                        AnimationDemoCard(
                            demo: demo,
                            language: language
                        ) { url in
                            selectedWebsite = Website(url: url)
                        }
                    }

                    Text(verbatim: "1.0.0(20261108)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .padding()
            }
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
            .overlay {
                if visibleDemos.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .navigationTitle("Animations")
            .searchable(text: $searchText, prompt: "Search titles or descriptions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort by Date", selection: $newestFirst) {
                            Text("Newest First").tag(true)
                            Text("Oldest First").tag(false)
                        }
                    } label: {
                        Label("Sort by Date", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    languageMenu
                }
            }
            .sheet(item: $selectedWebsite) { website in
                SafariView(url: website.url)
                    .ignoresSafeArea()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Language Menu

    private var languageMenu: some View {
        Menu {
            ForEach(AppLanguage.allCases) { item in
                Button {
                    languageCode = item.rawValue
                } label: {
                    if item == language {
                        Label {
                            Text(verbatim: item.displayName)
                        } icon: {
                            Image(systemName: "checkmark")
                        }
                    } else {
                        Text(verbatim: item.displayName)
                    }
                }
            }
        } label: {
            Image(systemName: "globe")
                .font(.title3)
        }
        .accessibilityLabel("Language")
    }
}

// MARK: - Animation Demo Card

struct AnimationDemoCard: View {

    let demo: AnimationDemo
    let language: AppLanguage

    // 同一个回调用于打开 YouTube 和 GitHub
    let openWebsite: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // MARK: Animation Navigation

            NavigationLink {
                demo.destination
            } label: {
                HStack(
                    alignment: .center,
                    spacing: 12
                ) {
                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {

                        Text(verbatim: demo.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)

                        Text(
                            verbatim: demo.description.localized(
                                for: language
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        Text(
                            demo.createdAt,
                            format: Date.FormatStyle(
                                date: .numeric,
                                time: .omitted,
                                locale: Locale(identifier: language.rawValue),
                                calendar: Calendar(identifier: .gregorian),
                                timeZone: .gmt
                            )
                        )
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // MARK: YouTube Preview

            if let url = demo.url {
                Divider()

                Button {
                    openWebsite(url)
                } label: {
                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {

                        URLPreview(url: url)
                            .frame(height: 120)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 12
                                )
                            )
                            .allowsHitTesting(false)

                        HStack {
                            Label {
                                Text(
                                    verbatim: demo.tutorialText.localized(
                                        for: language
                                    )
                                )
                            } icon: {
                                Image(
                                    systemName: "arrow.up.right.square"
                                )
                            }

                            Spacer()

                            Text(verbatim: url.host ?? "")
                                .lineLimit(1)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            // MARK: GitHub Source Code

            if let githubURL = demo.githubURL {

                Divider()

                Button {
                    openWebsite(githubURL)
                } label: {
                    HStack(spacing: 10) {

                        Image(
                            systemName: "chevron.left.forwardslash.chevron.right"
                        )
                        .font(.subheadline)

                        Text("View Code on GitHub")
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                    }
                    .foregroundStyle(.primary)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            // MARK: Assets Requirement

            if demo.requiresAssets {

                HStack {
                    Spacer()

                    Label(
                        "Assets Required",
                        systemImage: "photo.on.rectangle.angled"
                    )
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.orange)
                }
            }
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }
}

// MARK: - URL Preview

struct URLPreview: UIViewRepresentable {

    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(
        context: Context
    ) -> LPLinkView {

        let linkView = LPLinkView(url: url)

        linkView.isUserInteractionEnabled = false

        context.coordinator.loadMetadata(
            for: url,
            into: linkView
        )

        return linkView
    }

    func updateUIView(
        _ uiView: LPLinkView,
        context: Context
    ) {
        context.coordinator.loadMetadata(
            for: url,
            into: uiView
        )
    }

    static func dismantleUIView(
        _ uiView: LPLinkView,
        coordinator: Coordinator
    ) {
        coordinator.cancel()
    }

    // MARK: Coordinator

    final class Coordinator {

        private var provider: LPMetadataProvider?
        private var currentURL: URL?

        func loadMetadata(
            for url: URL,
            into linkView: LPLinkView
        ) {
            guard currentURL != url else {
                return
            }

            provider?.cancel()
            currentURL = url

            let metadataProvider = LPMetadataProvider()
            provider = metadataProvider

            metadataProvider.startFetchingMetadata(
                for: url
            ) { [weak self, weak linkView] metadata, _ in

                DispatchQueue.main.async {
                    guard
                        let self,
                        self.currentURL == url,
                        let metadata,
                        let linkView
                    else {
                        return
                    }

                    linkView.metadata = metadata
                }
            }
        }

        func cancel() {
            provider?.cancel()
            provider = nil
            currentURL = nil
        }
    }
}

// MARK: - Website Model

struct Website: Identifiable {

    let id = UUID()
    let url: URL
}

// MARK: - Safari Bottom Sheet

struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(
        context: Context
    ) -> SFSafariViewController {

        let controller = SFSafariViewController(
            url: url
        )

        controller.dismissButtonStyle = .close

        return controller
    }

    func updateUIViewController(
        _ controller: SFSafariViewController,
        context: Context
    ) {}
}

// MARK: - Preview

#Preview {
    ContentView()
}
