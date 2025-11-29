export interface Message {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: number
  state?: string
}

export interface Conversation {
  id: string
  title: string
  messages: Message[]
  createdAt: number
  updatedAt: number
  state: string
}

export interface PromptTemplate {
  id: string
  category: string
  title: string
  prompt: string
  icon: string
}

export type USState = {
  code: string
  name: string
}
