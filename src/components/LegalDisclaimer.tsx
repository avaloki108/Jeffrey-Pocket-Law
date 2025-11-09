import { Alert, AlertDescription } from '@/components/ui/alert'
import { Warning } from '@phosphor-icons/react'

export function LegalDisclaimer() {
  return (
    <Alert variant="default" className="border-accent/20 bg-accent/5">
      <Warning className="h-4 w-4 text-accent-foreground" weight="fill" />
      <AlertDescription className="text-xs leading-relaxed text-accent-foreground">
        <strong>Important Legal Disclaimer:</strong> This is legal information, not legal advice. 
        Responses are for informational purposes only. Laws vary by jurisdiction. 
        Always consult a qualified, licensed attorney for advice on your specific situation.
      </AlertDescription>
    </Alert>
  )
}
