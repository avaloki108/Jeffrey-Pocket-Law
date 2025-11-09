# Pocket Lawyer Web - Product Requirements Document

AI-powered legal information assistant providing accessible, accurate legal guidance through an intelligent chat interface.

**Experience Qualities**:
1. **Trustworthy**: Professional design with clear legal disclaimers establishes credibility and sets proper expectations that this is informational, not legal advice
2. **Accessible**: Simple, clear interface removes legal jargon barriers, making complex legal information understandable to everyone
3. **Intelligent**: Context-aware AI responses with state-specific filtering demonstrate sophisticated understanding while maintaining conversational ease

**Complexity Level**: Light Application (multiple features with basic state)
The app focuses on chat interaction with state context and prompt templates, using persistent storage for conversation history without requiring complex user accounts or advanced backend infrastructure.

## Essential Features

### AI Legal Chat Interface
- **Functionality**: Real-time conversational interface where users ask legal questions and receive AI-generated responses with appropriate disclaimers
- **Purpose**: Provides immediate access to legal information without expensive lawyer consultations
- **Trigger**: User types question in chat input or selects a prompt template
- **Progression**: User enters query → AI processes with state context → Response displays with disclaimer → User can ask follow-ups → Conversation persists
- **Success criteria**: Responses appear within 3 seconds, maintain conversation context, include proper legal disclaimers

### State-Specific Legal Context
- **Functionality**: State selector that filters and prioritizes legal information relevant to user's jurisdiction
- **Purpose**: Ensures legal guidance is applicable to user's location, as laws vary significantly by state
- **Trigger**: User selects state on first visit or changes via settings
- **Progression**: App loads → User selects home state → Selection persists → All queries automatically include state context → User can change state anytime
- **Success criteria**: State selection persists between sessions, visibly indicates current state, properly filters legal content

### Prompt Templates Library
- **Functionality**: Categorized library of pre-written legal query templates covering common legal scenarios
- **Purpose**: Helps users ask better questions and discover app capabilities across different legal domains
- **Trigger**: User clicks "Templates" or browses categories
- **Progression**: User opens templates → Browses categories (Employment, Real Estate, Criminal, Family, etc.) → Selects template → Template populates chat → User can customize → Submits query
- **Success criteria**: Templates organized into 8+ categories, one-click insertion into chat, covers most common legal questions

### Conversation History
- **Functionality**: Persistent storage of all chat conversations with sidebar navigation to browse, resume, and delete previous discussions
- **Purpose**: Users can reference past legal information and maintain ongoing legal research across multiple sessions
- **Trigger**: Conversations automatically save; users access via sidebar (desktop) or menu button (mobile)
- **Progression**: User asks question → Conversation auto-saves with title → Appears in sidebar → User can click to resume → Continue from where they left off → Delete unwanted conversations
- **Success criteria**: All conversations persist between sessions, automatically titled from first message, sorted by recency, individually deletable, seamless switching between conversations

## Edge Case Handling

- **No State Selected**: Display prominent state selector modal on first visit, default to "General (Federal)" if skipped
- **API Failures**: Show friendly error message, offer to retry, degrade gracefully to cached responses if available
- **Empty Conversations**: Show helpful placeholder with example questions and template suggestions
- **Very Long Responses**: Implement scrollable response containers with "Show more/less" for readability
- **Inappropriate Queries**: AI responds with reminder of app purpose and redirects to appropriate legal resources
- **Rapid-Fire Questions**: Disable input during processing to prevent queue buildup

## Design Direction

The design should feel professional, trustworthy, and calm—like a well-appointed law library modernized for the digital age. Think clean lines, sophisticated typography, and a sense of gravitas that respects the seriousness of legal matters while remaining approachable. The interface should project quiet confidence through generous white space and purposeful restraint, avoiding playful elements that might undermine the gravity of legal information.

## Color Selection

**Complementary palette** - Deep navy blue paired with warm gold accents to evoke trust and authority.

Navy blue represents law, order, and professionalism (think legal briefs and judicial robes), while gold adds a touch of prestige and highlights important actions. This classic legal color scheme instills confidence while remaining modern and accessible.

- **Primary Color**: Deep navy blue `oklch(0.25 0.05 250)` - Represents authority, trust, and legal professionalism; used for headers, primary actions, and key UI elements
- **Secondary Colors**: Slate gray `oklch(0.45 0.01 250)` for supporting text and backgrounds, creating hierarchy without harshness
- **Accent Color**: Warm gold `oklch(0.70 0.12 75)` - Highlights CTAs, active states, and important notices with a touch of prestige
- **Foreground/Background Pairings**:
  - Background (White `oklch(0.99 0 0)`): Dark navy text `oklch(0.20 0.05 250)` - Ratio 12.1:1 ✓
  - Card (Light gray `oklch(0.97 0 0)`): Navy text `oklch(0.20 0.05 250)` - Ratio 11.3:1 ✓
  - Primary (Navy `oklch(0.25 0.05 250)`): White text `oklch(0.99 0 0)` - Ratio 12.1:1 ✓
  - Accent (Gold `oklch(0.70 0.12 75)`): Navy text `oklch(0.20 0.05 250)` - Ratio 6.2:1 ✓
  - Muted (Light slate `oklch(0.95 0.01 250)`): Dark gray text `oklch(0.45 0.01 250)` - Ratio 7.8:1 ✓

## Font Selection

Professional serif for headings to evoke legal documents and tradition, paired with clean sans-serif for body text to ensure readability and modern accessibility.

**Primary Font**: Playfair Display (serif) for headings - conveys legal authority and classical sophistication
**Secondary Font**: Inter (sans-serif) for body text - ensures excellent readability and modern professionalism

- **Typographic Hierarchy**:
  - H1 (App Title): Playfair Display Bold/32px/tight letter spacing - Commands authority
  - H2 (Section Headers): Playfair Display Semibold/24px/normal spacing - Organizes content clearly
  - H3 (Chat Messages): Inter Semibold/16px/normal spacing - Distinguishes speakers
  - Body (Legal Content): Inter Regular/15px/1.6 line-height - Optimizes readability for dense legal text
  - Small (Disclaimers): Inter Regular/13px/1.5 line-height - Ensures critical notices remain legible

## Animations

Animations should be subtle and purposeful, reinforcing the professional nature of legal consultation—smooth transitions that feel deliberate rather than playful, with the restraint of a courtroom rather than the energy of a playground.

- **Purposeful Meaning**: Smooth fade-ins for new messages suggest thoughtful deliberation; state selection transitions feel decisive and committed
- **Hierarchy of Movement**: Chat messages receive gentle slide-up animations to draw attention; navigation transitions are quick fades to avoid distraction from content

## Component Selection

- **Components**:
  - **Chat Interface**: Custom scrollable message list with distinct styling for user vs AI messages; AI messages in card components with subtle elevation
  - **Input Area**: Shadcn Textarea with send Button, grows with content, max 4 lines before scroll
  - **State Selector**: Shadcn Select dropdown with search for 50 states, persistent indicator in header
  - **Templates**: Shadcn Accordion for categories, Card components for individual templates with hover states
  - **Navigation**: Shadcn Tabs for main sections (Chat, Templates, History)
  - **Disclaimers**: Shadcn Alert component with warning variant, non-dismissible in key locations
  - **History Sidebar**: Shadcn Sheet slide-out panel with ScrollArea for conversation list
  
- **Customizations**:
  - Custom legal disclaimer banner component (always visible, subtle but persistent)
  - Custom message bubble components with distinct user/AI styling and markdown rendering
  - Custom template card with category badge and one-click insertion
  
- **States**:
  - Buttons: Default navy, hover with slight brightness increase, active with depth, disabled with reduced opacity
  - Input: Default with subtle border, focus with gold accent ring, error state for validation
  - Messages: User messages right-aligned with lighter background, AI messages left-aligned in cards with timestamp
  
- **Icon Selection**:
  - Scales (justice): App logo and branding
  - ChatCircle: Chat/conversation actions
  - MapPin: State selection and location context
  - BookOpen: Legal templates and resources
  - Warning: Disclaimer and important notices
  - ClockCounterClockwise: Conversation history
  
- **Spacing**:
  - Container padding: px-6 py-8 for main content areas
  - Card padding: p-6 for consistent internal spacing
  - Message spacing: gap-4 between messages, gap-2 for message metadata
  - Section spacing: mb-8 between major sections, mb-4 between related elements
  
- **Mobile**:
  - Single column layout on mobile, full-width cards
  - Bottom-fixed input area with safe area padding
  - Hamburger menu for navigation tabs on mobile
  - Templates and history as full-screen modals rather than sidebars
  - Larger touch targets (min 44px) for all interactive elements
  - State selector moves to prominent header position on mobile
