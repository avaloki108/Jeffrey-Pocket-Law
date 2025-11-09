import { Message } from '@/lib/types'
import { Card } from '@/components/ui/card'
import { cn } from '@/lib/utils'

interface MessageBubbleProps {
  message: Message
}

export function MessageBubble({ message }: MessageBubbleProps) {
  const isUser = message.role === 'user'
  const timestamp = new Date(message.timestamp).toLocaleTimeString([], {
    hour: '2-digit',
    minute: '2-digit',
  })

  if (isUser) {
    return (
      <div className="flex justify-end">
        <div className="max-w-[80%]">
          <div className="rounded-lg bg-primary px-4 py-3 text-primary-foreground">
            <p className="whitespace-pre-wrap text-sm leading-relaxed">{message.content}</p>
          </div>
          <p className="mt-1 text-right text-xs text-muted-foreground">{timestamp}</p>
        </div>
      </div>
    )
  }

  return (
    <div className="flex justify-start">
      <div className="max-w-[85%]">
        <Card className="border-border/50 bg-card px-4 py-3 shadow-sm">
          <div className="mb-2 flex items-center gap-2">
            <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary text-xs font-semibold text-primary-foreground">
              AI
            </div>
            <span className="text-xs font-medium text-muted-foreground">Pocket Lawyer</span>
          </div>
          <div className="prose prose-sm max-w-none">
            <p className="whitespace-pre-wrap text-sm leading-relaxed text-foreground">
              {message.content}
            </p>
          </div>
        </Card>
        <p className="mt-1 text-xs text-muted-foreground">{timestamp}</p>
      </div>
    </div>
  )
}
