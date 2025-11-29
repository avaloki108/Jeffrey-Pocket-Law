import { Conversation } from '@/lib/types'
import { Button } from '@/components/ui/button'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Card } from '@/components/ui/card'
import { ChatCircle, Trash, ClockCounterClockwise } from '@phosphor-icons/react'
import { cn } from '@/lib/utils'

interface ConversationHistoryProps {
  conversations: Conversation[]
  currentConversationId: string | null
  onSelectConversation: (id: string) => void
  onDeleteConversation: (id: string) => void
  onNewConversation: () => void
}

export function ConversationHistory({
  conversations,
  currentConversationId,
  onSelectConversation,
  onDeleteConversation,
  onNewConversation,
}: ConversationHistoryProps) {
  const sortedConversations = [...conversations].sort((a, b) => b.updatedAt - a.updatedAt)

  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp)
    const now = new Date()
    const diffInMs = now.getTime() - date.getTime()
    const diffInHours = diffInMs / (1000 * 60 * 60)
    const diffInDays = diffInMs / (1000 * 60 * 60 * 24)

    if (diffInHours < 24) {
      return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    } else if (diffInDays < 7) {
      return date.toLocaleDateString([], { weekday: 'short' })
    } else {
      return date.toLocaleDateString([], { month: 'short', day: 'numeric' })
    }
  }

  const getMessagePreview = (conversation: Conversation) => {
    const firstUserMessage = conversation.messages.find((m) => m.role === 'user')
    if (!firstUserMessage) return 'New conversation'
    return firstUserMessage.content.slice(0, 60) + (firstUserMessage.content.length > 60 ? '...' : '')
  }

  return (
    <div className="flex h-full flex-col">
      <div className="border-b border-border p-4">
        <div className="mb-4 flex items-center gap-2">
          <ClockCounterClockwise className="h-5 w-5 text-primary" weight="fill" />
          <h2 className="text-lg font-semibold text-foreground">History</h2>
        </div>
        <Button onClick={onNewConversation} className="w-full gap-2" size="sm">
          <ChatCircle className="h-4 w-4" weight="fill" />
          New Conversation
        </Button>
      </div>

      <ScrollArea className="flex-1">
        <div className="space-y-2 p-4">
          {sortedConversations.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <ClockCounterClockwise className="mb-3 h-12 w-12 text-muted-foreground/30" weight="thin" />
              <p className="text-sm text-muted-foreground">No conversations yet</p>
              <p className="mt-1 text-xs text-muted-foreground">
                Start chatting to build your history
              </p>
            </div>
          ) : (
            sortedConversations.map((conversation) => (
              <Card
                key={conversation.id}
                className={cn(
                  'group relative cursor-pointer border-border/50 p-3 transition-all hover:border-primary/50 hover:bg-accent/5',
                  currentConversationId === conversation.id && 'border-primary bg-accent/10'
                )}
                onClick={() => onSelectConversation(conversation.id)}
              >
                <div className="pr-8">
                  <div className="mb-1 flex items-center justify-between gap-2">
                    <h3 className="truncate text-sm font-medium text-foreground">
                      {conversation.title}
                    </h3>
                  </div>
                  <p className="mb-2 line-clamp-2 text-xs text-muted-foreground">
                    {getMessagePreview(conversation)}
                  </p>
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <span>{formatDate(conversation.updatedAt)}</span>
                    <span>•</span>
                    <span>{conversation.messages.length} msg</span>
                    {conversation.state && (
                      <>
                        <span>•</span>
                        <span className="font-medium">{conversation.state}</span>
                      </>
                    )}
                  </div>
                </div>
                <Button
                  variant="ghost"
                  size="icon"
                  className="absolute right-2 top-2 h-7 w-7 opacity-0 transition-opacity group-hover:opacity-100"
                  onClick={(e) => {
                    e.stopPropagation()
                    onDeleteConversation(conversation.id)
                  }}
                >
                  <Trash className="h-4 w-4 text-destructive" weight="fill" />
                </Button>
              </Card>
            ))
          )}
        </div>
      </ScrollArea>
    </div>
  )
}
