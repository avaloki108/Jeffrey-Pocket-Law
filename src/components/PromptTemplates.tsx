import { PROMPT_TEMPLATES } from '@/lib/constants'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion'
import {
  Briefcase,
  House,
  Siren,
  Users,
  Buildings,
  ShieldCheck,
  FirstAid,
  Receipt,
  IdentificationCard,
} from '@phosphor-icons/react'

interface PromptTemplatesProps {
  onSelectTemplate: (prompt: string) => void
  selectedState: string
}

const iconMap: Record<string, React.ComponentType<any>> = {
  Briefcase,
  House,
  Siren,
  Users,
  Buildings,
  ShieldCheck,
  FirstAid,
  Receipt,
  Passport: IdentificationCard,
}

export function PromptTemplates({ onSelectTemplate, selectedState }: PromptTemplatesProps) {
  const categories = Array.from(new Set(PROMPT_TEMPLATES.map((t) => t.category)))
  const stateName = selectedState ? `in ${selectedState}` : ''

  const handleTemplateClick = (prompt: string) => {
    const filledPrompt = prompt.replace('[STATE]', selectedState || 'your state')
    onSelectTemplate(filledPrompt)
  }

  return (
    <div className="space-y-4">
      <div>
        <h2 className="text-2xl font-semibold text-foreground">Legal Question Templates</h2>
        <p className="text-sm text-muted-foreground">
          Browse common legal questions by category. Click any template to ask the question.
        </p>
      </div>

      <Accordion type="single" collapsible className="w-full">
        {categories.map((category) => {
          const templates = PROMPT_TEMPLATES.filter((t) => t.category === category)
          const Icon = iconMap[templates[0]?.icon] || Briefcase

          return (
            <AccordionItem key={category} value={category}>
              <AccordionTrigger className="text-left hover:no-underline">
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
                    <Icon className="h-5 w-5 text-primary" weight="duotone" />
                  </div>
                  <div>
                    <div className="font-semibold text-foreground">{category}</div>
                    <div className="text-xs text-muted-foreground">
                      {templates.length} template{templates.length !== 1 ? 's' : ''}
                    </div>
                  </div>
                </div>
              </AccordionTrigger>
              <AccordionContent>
                <div className="ml-[52px] mt-2 space-y-2">
                  {templates.map((template) => (
                    <Card
                      key={template.id}
                      className="cursor-pointer border-border/50 p-4 transition-colors hover:border-primary/50 hover:bg-accent/5"
                      onClick={() => handleTemplateClick(template.prompt)}
                    >
                      <h4 className="mb-1 font-medium text-foreground">{template.title}</h4>
                      <p className="text-sm text-muted-foreground">
                        {template.prompt.replace('[STATE]', selectedState || 'your state')}
                      </p>
                    </Card>
                  ))}
                </div>
              </AccordionContent>
            </AccordionItem>
          )
        })}
      </Accordion>
    </div>
  )
}
