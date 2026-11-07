//
//  ChatBubbleTextFieldTransitionUsingSwiftUI.swift
//  KavsoftDemos
//
//  Created by 吕海锋 on 2026/11/7.
//

import SwiftUI

// MARK: - Environment
extension EnvironmentValues {
    @Entry var messageFieldSize: CGSize = .zero
}

// MARK: - Model
struct Message: Identifiable {
    var id: String
    var content: String
    var isFit: Bool?

    init(content: String) {
        self.id = UUID().uuidString
        self.content = content
        self.isFit = nil
    }

    static var placeholderMessages: [Message] {
        [
            .init(content: "Hello, my name is Eduardo"),
            .init(content: "This is Chat Bubble Transition Using SwiftUI!"),
        ]
    }
}

// MARK: - Chat View
struct ChatView: View {
    @State private var allMessages: [Message] = Message.placeholderMessages
    @State private var currentMessage: Message = .init(content: "")
    @State private var messageFieldSize: CGSize = .zero
    @Namespace private var namespace

    private let horizontalPadding: CGFloat = 12

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(allMessages) { message in
                    let isVisible = currentMessage.id != message.id

                    MessageBubble(
                        isVisible: isVisible,
                        message: message,
                        namespace: namespace
                    )
                }
            }
            .padding(15)
        }
        .defaultScrollAnchor(.bottom)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomBar()
        }
        .environment(\.messageFieldSize, messageFieldSize)
    }

    // 底部输入栏
    @ViewBuilder
    private func BottomBar() -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField(
                "Type a message",
                text: $currentMessage.content,
                axis: .vertical
            )
            .font(.body)
            .lineLimit(6)
            .padding(horizontalPadding)
            .chatInputBackground()
            .overlay(alignment: .topLeading) {
                ForEach(allMessages) { message in
                    if currentMessage.id == message.id {
                        TemporaryMessageTransitionSource(currentMessage)
                    }
                }
            }
            .onGeometryChange(for: CGSize.self) {
                $0.size
            } action: { newValue in
                messageFieldSize = newValue
            }

            Button(action: sendMessage) {
                Image(systemName: "paperplane")
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(width: 25, height: 35)
            }
            .chatSendButtonStyle()
            .disabled(currentMessage.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }

    // 临时过渡源（从输入框出发飞往聊天流）
    @ViewBuilder
    private func TemporaryMessageTransitionSource(_ message: Message) -> some View {
        let isFit = message.isFit ?? false

        Text(message.content)
            .font(.body)
            .padding(12)
            .frame(maxWidth: isFit ? .infinity : nil, alignment: .leading)
            .background(Color(UIColor.systemGray6))
            .clipShape(.rect(cornerRadius: 25))
            .matchedGeometryEffect(id: message.id, in: namespace, properties: isFit ? [.position, .size] : [.position])
    }

    private func sendMessage() {
        let trimmed = currentMessage.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        currentMessage.content = trimmed

        let hasNewline = currentMessage.content.contains("\n")
        let textWidth = calculateTextSize(
            text: currentMessage.content,
            fontStyle: .body
        ).width
        let contentPadding: CGFloat = horizontalPadding * 2
        let isFit = !hasNewline && (textWidth < (messageFieldSize.width - contentPadding))
        currentMessage.isFit = isFit

        allMessages.append(currentMessage)
        DispatchQueue.main.async {
            let reference = currentMessage

            withAnimation(animation, completionCriteria: .removed) {
                currentMessage = .init(content: "")
            } completion: {
                if let index = allMessages.firstIndex(where: { $0.id == reference.id }) {
                    allMessages[index].isFit = nil
                }
            }
        }
    }

    private func calculateTextSize(text: String, fontStyle: UIFont.TextStyle) -> CGSize {
        NSString(string: text).size(withAttributes: [
            .font: UIFont.preferredFont(forTextStyle: fontStyle)
        ])
    }

    private var animation: Animation {
        .interpolatingSpring(duration: 0.3, bounce: 0, initialVelocity: 0)
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    var isVisible: Bool
    var message: Message
    var namespace: Namespace.ID
    @Environment(\.messageFieldSize) private var messageFieldSize

    var body: some View {
        let isFit = message.isFit ?? false

        ZStack {
            if isVisible {
                Text(message.content)
                    .font(.body)
                    .padding(12)
                    .frame(maxWidth: isFit ? .infinity : nil, alignment: .leading)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(.rect(cornerRadius: 25))
                    .matchedGeometryEffect(id: message.id, in: namespace, properties: isFit ? [.position, .size] : [.position])
                    .padding(.top, 10)
            }
        }
        .fixedSize(horizontal: isFit ? isVisible : false, vertical: true)
        .compositingGroup()
        .keyframeAnimator(initialValue: CGFloat.zero, trigger: isVisible) { [messageFieldSize] content, progress in
            content
                .offset(y: (messageFieldSize.height * 0.55) * progress)
        } keyframes: { _ in
            CubicKeyframe(1, duration: 0.15)
            CubicKeyframe(0, duration: 0.15)
        }
        .frame(maxWidth: messageFieldSize.width, alignment: .trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// MARK: - 样式兼容扩展
private extension View {
    @ViewBuilder
    func chatInputBackground() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 25))
        } else {
            self.background(.ultraThinMaterial, in: .rect(cornerRadius: 25))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    func chatSendButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
        } else {
            self.buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
        }
    }
}

// MARK: - App 根视图
struct ChatBubbleTextFieldTransitionUsingSwiftUI: View {
    var body: some View {
        NavigationStack {
            ChatView()
                .navigationTitle("Chat Bubble Transition")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
