import { useState, useRef, useEffect } from 'react'
import { useKV } from '@github/spark/hooks'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Button } from '@/components/ui/button'
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet'
import { LegalDisclaimer } from '@/components/LegalDisclaimer'
import { MessageBubble } from '@/components/MessageBubble'
import { ChatInput } from '@/components/ChatInput'
import { StateSelector } from '@/components/StateSelector'
import { PromptTemplates } from '@/components/PromptTemplates'
import { ConversationHistory } from '@/components/ConversationHistory'
import { Message, Conversation } from '@/lib/types'
import { Scales, ChatCircle, BookOpen, ClockCounterClockwise, List } from '@phosphor-icons/react'
import { toast } from 'sonner'

function App() {
  const [conversations, setConversations] = useKV<Conversation[]>('conversations', [])
  const [currentConversationId, setCurrentConversationId] = useKV<string | null>('current-conversation-id', null)
  const [selectedState, setSelectedState] = useKV<string>('selected-state', 'CA')
  const [isProcessing, setIsProcessing] = useState(false)
  const [activeTab, setActiveTab] = useState('chat')
  const [isHistoryOpen, setIsHistoryOpen] = useState(false)
  const scrollAreaRef = useRef<HTMLDivElement>(null)

  const conversationsValue = conversations ?? []
  const currentConversation = conversationsValue.find((c) => c.id === currentConversationId)
  const messagesValue = currentConversation?.messages ?? []
  const stateValue = selectedState ?? 'CA'

  useEffect(() => {
    if (scrollAreaRef.current) {
      const scrollContainer = scrollAreaRef.current.querySelector('[data-radix-scroll-area-viewport]')
      if (scrollContainer) {
        scrollContainer.scrollTop = scrollContainer.scrollHeight
      }
    }
  }, [messagesValue])

  const createNewConversation = () => {
    const newConversation: Conversation = {
      id: `conv-${Date.now()}`,
      title: 'New Conversation',
      messages: [],
      createdAt: Date.now(),
      updatedAt: Date.now(),
      state: stateValue,
    }
    setConversations((current) => [...(current ?? []), newConversation])
    setCurrentConversationId(newConversation.id)
    return newConversation.id
  }

  const updateConversation = (conversationId: string, messages: Message[]) => {
    setConversations((current) => {
      const updated = (current ?? []).map((conv) => {
        if (conv.id === conversationId) {
          const firstUserMessage = messages.find((m) => m.role === 'user')
          const title = firstUserMessage
            ? firstUserMessage.content.slice(0, 50) + (firstUserMessage.content.length > 50 ? '...' : '')
            : 'New Conversation'
          
          return {
            ...conv,
            messages,
            title,
            updatedAt: Date.now(),
            state: stateValue,
          }
        }
        return conv
      })
      return updated
    })
  }

  const handleSendMessage = async (content: string) => {
    let convId = currentConversationId
    
    if (!convId || !conversationsValue.find((c) => c.id === convId)) {
      convId = createNewConversation()
    }

    const userMessage: Message = {
      id: `msg-${Date.now()}`,
      role: 'user',
      content,
      timestamp: Date.now(),
      state: stateValue,
    }

    const currentConv = conversationsValue.find((c) => c.id === convId)
    const updatedMessages = [...(currentConv?.messages ?? []), userMessage]
    updateConversation(convId, updatedMessages)
    setIsProcessing(true)

    try {
      const stateName = stateValue
      const promptText = `You are Pocket Lawyer, an AI legal assistant providing legal information (not legal advice) to users.

Context:
- User's state: ${stateName}
- User question: ${content}

Instructions:
1. Provide accurate legal information relevant to ${stateName} law when applicable
2. If the question is state-specific, focus on ${stateName} statutes and regulations
3. Include federal law context when relevant
4. Be clear that this is information, not legal advice
5. Suggest when the user should consult a licensed attorney
6. Keep responses concise but informative (2-4 paragraphs)
7. Use plain language, avoiding excessive legal jargon

Provide your response:`

      const response = await window.spark.llm(promptText, 'gpt-4o')

      const assistantMessage: Message = {
        id: `msg-${Date.now()}`,
        role: 'assistant',
        content: response,
        timestamp: Date.now(),
        state: stateValue,
      }

      const finalMessages = [...updatedMessages, assistantMessage]
      updateConversation(convId, finalMessages)
    } catch (error) {
      toast.error('Failed to get response. Please try again.')
      console.error('Error getting AI response:', error)
    } finally {
      setIsProcessing(false)
    }
  }

  const handleTemplateSelect = (prompt: string) => {
    setActiveTab('chat')
    setTimeout(() => {
      handleSendMessage(prompt)
    }, 100)
  }

  const handleClearChat = () => {
    if (currentConversationId && confirm('Are you sure you want to clear this conversation?')) {
      setConversations((current) => (current ?? []).filter((c) => c.id !== currentConversationId))
      setCurrentConversationId(null)
      toast.success('Conversation cleared')
    }
  }

  const handleSelectConversation = (id: string) => {
    setCurrentConversationId(id)
    setIsHistoryOpen(false)
    setActiveTab('chat')
  }

  const handleDeleteConversation = (id: string) => {
    if (confirm('Delete this conversation?')) {
      setConversations((current) => (current ?? []).filter((c) => c.id !== id))
      if (currentConversationId === id) {
        setCurrentConversationId(null)
      }
      toast.success('Conversation deleted')
    }
  }

  const handleNewConversation = () => {
    setCurrentConversationId(null)
    setIsHistoryOpen(false)
    setActiveTab('chat')
  }

  return (
    <div className="flex h-screen flex-col bg-background">
      <header className="border-b border-border bg-card px-6 py-4">
        <div className="mx-auto flex max-w-6xl items-center justify-between">
          <div className="flex items-center gap-3">
            <Sheet open={isHistoryOpen} onOpenChange={setIsHistoryOpen}>
              <SheetTrigger asChild>
                <Button variant="ghost" size="icon" className="md:hidden">
                  <List className="h-5 w-5" weight="bold" />
                </Button>
              </SheetTrigger>
              <SheetContent side="left" className="w-80 p-0">
                <ConversationHistory
                  conversations={conversationsValue}
                  currentConversationId={currentConversationId ?? null}
                  onSelectConversation={handleSelectConversation}
                  onDeleteConversation={handleDeleteConversation}
                  onNewConversation={handleNewConversation}
                />
              </SheetContent>
            </Sheet>
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary">
              <Scales className="h-6 w-6 text-primary-foreground" weight="fill" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-foreground">Pocket Lawyer</h1>
              <p className="text-xs text-muted-foreground">AI Legal Information Assistant</p>
            </div>
          </div>
          <StateSelector selectedState={stateValue} onStateChange={setSelectedState} />
        </div>
      </header>

      <div className="flex flex-1 overflow-hidden">
        <aside className="hidden w-80 border-r border-border bg-card md:block">
          <ConversationHistory
            conversations={conversationsValue}
            currentConversationId={currentConversationId ?? null}
            onSelectConversation={handleSelectConversation}
            onDeleteConversation={handleDeleteConversation}
            onNewConversation={handleNewConversation}
          />
        </aside>

        <div className="mx-auto w-full max-w-4xl flex-1 overflow-hidden px-6 py-6">
          <LegalDisclaimer />

          <Tabs value={activeTab} onValueChange={setActiveTab} className="mt-6 flex h-[calc(100vh-220px)] flex-col">
            <TabsList className="grid w-full max-w-md grid-cols-2">
              <TabsTrigger value="chat" className="gap-2">
                <ChatCircle className="h-4 w-4" weight="fill" />
                Chat
              </TabsTrigger>
              <TabsTrigger value="templates" className="gap-2">
                <BookOpen className="h-4 w-4" weight="fill" />
                Templates
              </TabsTrigger>
            </TabsList>

            <TabsContent value="chat" className="flex flex-1 flex-col overflow-hidden">
              <div className="mb-4 flex items-center justify-between">
                <p className="text-sm text-muted-foreground">
                  {messagesValue.length === 0
                    ? 'Start a conversation or use a template'
                    : `${messagesValue.length} message${messagesValue.length !== 1 ? 's' : ''}`}
                </p>
                {messagesValue.length > 0 && (
                  <Button variant="ghost" size="sm" onClick={handleClearChat}>
                    Clear Chat
                  </Button>
                )}
              </div>

              <ScrollArea ref={scrollAreaRef} className="flex-1 pr-4">
                <div className="space-y-4 pb-4">
                  {messagesValue.length === 0 ? (
                    <div className="flex h-full min-h-[300px] flex-col items-center justify-center text-center">
                      <Scales className="mb-4 h-16 w-16 text-muted-foreground/50" weight="thin" />
                      <h3 className="mb-2 text-lg font-semibold text-foreground">
                        Welcome to Pocket Lawyer
                      </h3>
                      <p className="mb-6 max-w-md text-sm text-muted-foreground">
                        Ask any legal question or browse our templates to get started. All responses are
                        tailored to your selected state.
                      </p>
                      <Button
                        variant="outline"
                        onClick={() => setActiveTab('templates')}
                        className="gap-2"
                      >
                        <BookOpen className="h-4 w-4" weight="fill" />
                        Browse Templates
                      </Button>
                    </div>
                  ) : (
                    messagesValue.map((message) => <MessageBubble key={message.id} message={message} />)
                  )}
                </div>
              </ScrollArea>

              <div className="mt-4 pt-4">
                <ChatInput onSendMessage={handleSendMessage} disabled={isProcessing} />
              </div>
            </TabsContent>

            <TabsContent value="templates" className="flex-1 overflow-hidden">
              <ScrollArea className="h-full pr-4">
                <PromptTemplates
                  onSelectTemplate={handleTemplateSelect}
                  selectedState={stateValue}
                />
              </ScrollArea>
            </TabsContent>
          </Tabs>
        </div>
      </div>
    </div>
  )
}

export default App
