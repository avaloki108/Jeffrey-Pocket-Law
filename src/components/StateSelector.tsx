import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { US_STATES } from '@/lib/constants'
import { MapPin } from '@phosphor-icons/react'

interface StateSelectorProps {
  selectedState: string
  onStateChange: (state: string) => void
}

export function StateSelector({ selectedState, onStateChange }: StateSelectorProps) {
  const selectedStateName = US_STATES.find((s) => s.code === selectedState)?.name || 'Select State'

  return (
    <div className="flex items-center gap-2">
      <MapPin className="h-4 w-4 text-muted-foreground" weight="fill" />
      <Select value={selectedState} onValueChange={onStateChange}>
        <SelectTrigger id="state-selector" className="w-[180px]">
          <SelectValue placeholder="Select State">{selectedStateName}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          {US_STATES.map((state) => (
            <SelectItem key={state.code} value={state.code}>
              {state.name}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  )
}
