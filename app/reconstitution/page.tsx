"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Checkbox } from "@/components/ui/checkbox"
import { useAppContext } from "@/lib/app-context"
import { scanHistory, kitReferences } from "@/lib/mock-data"
import { toast } from "sonner"
import {
  ArrowLeft,
  Wrench,
  CheckCircle,
  XCircle,
  AlertTriangle,
  ArrowRight,
  ArrowDown,
  Package,
  RotateCcw,
  ScanLine,
  Award,
} from "lucide-react"

interface ReconStep {
  id: string
  type: "add" | "remove" | "verify"
  instrumentName: string
  instrumentId: string
  instruction: string
  position: string
  completed: boolean
}

export default function ReconstitutionPage() {
  const router = useRouter()
  const { currentScan } = useAppContext()

  const scan = currentScan || scanHistory[0]
  const kit = kitReferences.find((k) => k.id === scan?.kitReferenceId)

  // Build reconstitution steps from scan anomalies
  const buildSteps = (): ReconStep[] => {
    if (!scan) return []
    const steps: ReconStep[] = []
    let idx = 0

    // Missing instruments → need to add
    scan.detectedInstruments
      .filter((d) => d.status === "missing")
      .forEach((d) => {
        steps.push({
          id: `step-${idx++}`,
          type: "add",
          instrumentName: d.name,
          instrumentId: d.instrumentId,
          instruction: `Récupérer "${d.name}" dans le stock de stérilisation et le placer dans le kit`,
          position: `Emplacement prévu dans le kit de référence`,
          completed: false,
        })
      })

    // Extra instruments → need to remove
    scan.detectedInstruments
      .filter((d) => d.status === "extra")
      .forEach((d) => {
        steps.push({
          id: `step-${idx++}`,
          type: "remove",
          instrumentName: d.name,
          instrumentId: d.instrumentId,
          instruction: `Retirer "${d.name}" du kit et le remettre dans le stock approprié`,
          position: `À retirer du kit`,
          completed: false,
        })
      })

    // Final verification step
    steps.push({
      id: `step-${idx}`,
      type: "verify",
      instrumentName: "Validation finale",
      instrumentId: "VALIDATE",
      instruction: "Scanner le kit reconstitué pour confirmer la conformité",
      position: "—",
      completed: false,
    })

    return steps
  }

  const [steps, setSteps] = useState<ReconStep[]>(buildSteps)
  const [activeStep, setActiveStep] = useState(0)
  const [isValidating, setIsValidating] = useState(false)
  const [isComplete, setIsComplete] = useState(false)

  const completedCount = steps.filter((s) => s.completed).length
  const progress = steps.length > 0 ? Math.round((completedCount / steps.length) * 100) : 0

  const toggleStep = (index: number) => {
    setSteps((prev) =>
      prev.map((s, i) => (i === index ? { ...s, completed: !s.completed } : s))
    )
  }

  const completeCurrentStep = () => {
    if (activeStep < steps.length) {
      setSteps((prev) =>
        prev.map((s, i) => (i === activeStep ? { ...s, completed: true } : s))
      )

      if (activeStep === steps.length - 1) {
        // Last step - validate
        setIsValidating(true)
        setTimeout(() => {
          setIsValidating(false)
          setIsComplete(true)
          toast.success("Kit reconstitué avec succès !")
        }, 2000)
      } else {
        setActiveStep((prev) => prev + 1)
        toast.success("Étape complétée !")
      }
    }
  }

  if (!scan) {
    return (
      <div className="p-8 flex flex-col items-center justify-center min-h-[60vh] space-y-4">
        <Package className="w-16 h-16 text-slate-300" />
        <p className="text-slate-500 text-lg">Aucun scan disponible pour reconstitution</p>
        <Button onClick={() => router.push("/scanner")}>Lancer un scan</Button>
      </div>
    )
  }

  if (isComplete) {
    return (
      <div className="p-4 md:p-8 max-w-3xl mx-auto">
        <Card className="border-0 shadow-lg bg-gradient-to-br from-emerald-50 to-green-50">
          <CardContent className="p-8 md:p-12 text-center space-y-6">
            <div className="w-24 h-24 rounded-full bg-emerald-500 flex items-center justify-center mx-auto shadow-lg shadow-emerald-200">
              <Award className="w-12 h-12 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-emerald-800">Reconstitution Terminée</h2>
              <p className="text-emerald-600 mt-2">
                Le kit &quot;{scan.kitReferenceName}&quot; a été reconstitué avec succès
              </p>
            </div>
            <div className="grid grid-cols-3 gap-4 max-w-sm mx-auto">
              <div className="p-3 rounded-xl bg-white shadow-sm">
                <p className="text-xl font-bold text-emerald-600">{steps.length}</p>
                <p className="text-xs text-slate-500">Étapes</p>
              </div>
              <div className="p-3 rounded-xl bg-white shadow-sm">
                <p className="text-xl font-bold text-emerald-600">100%</p>
                <p className="text-xs text-slate-500">Complété</p>
              </div>
              <div className="p-3 rounded-xl bg-white shadow-sm">
                <p className="text-xl font-bold text-emerald-600">
                  <CheckCircle className="w-5 h-5 mx-auto" />
                </p>
                <p className="text-xs text-slate-500">Validé</p>
              </div>
            </div>
            <div className="flex flex-wrap gap-3 justify-center pt-4">
              <Button variant="outline" onClick={() => router.push("/historique")}>
                Voir l&apos;historique
              </Button>
              <Button
                onClick={() => router.push("/scanner")}
                className="bg-gradient-to-r from-indigo-600 to-blue-600"
              >
                <ScanLine className="w-4 h-4 mr-2" />
                Nouveau Scan
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-5xl mx-auto">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div className="flex items-center gap-3 ml-12 md:ml-0">
          <Button variant="ghost" size="icon" onClick={() => router.back()}>
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-slate-900">Reconstitution Guidée</h1>
            <p className="text-slate-500 mt-1">{scan.kitReferenceName}</p>
          </div>
        </div>
        <Button
          variant="outline"
          onClick={() => {
            setSteps(buildSteps())
            setActiveStep(0)
            setIsComplete(false)
          }}
        >
          <RotateCcw className="w-4 h-4 mr-2" />
          Recommencer
        </Button>
      </div>

      {/* Progress */}
      <Card className="border-0 shadow-md">
        <CardContent className="p-5">
          <div className="flex items-center justify-between mb-3">
            <span className="text-sm font-medium text-slate-700">
              Progression : {completedCount}/{steps.length} étapes
            </span>
            <span className="text-sm font-bold text-indigo-600">{progress}%</span>
          </div>
          <Progress value={progress} className="h-3" />
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Steps List */}
        <div className="lg:col-span-2 space-y-3">
          {steps.map((step, index) => {
            const isActive = index === activeStep
            const isPast = step.completed

            return (
              <Card
                key={step.id}
                className={`border-0 shadow-md transition-all duration-300 ${
                  isActive
                    ? "ring-2 ring-indigo-500 shadow-lg"
                    : isPast
                    ? "opacity-75"
                    : "opacity-60"
                }`}
              >
                <CardContent className="p-5">
                  <div className="flex items-start gap-4">
                    {/* Step Number / Check */}
                    <div
                      className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${
                        isPast
                          ? "bg-emerald-500"
                          : isActive
                          ? "bg-indigo-500"
                          : "bg-slate-200"
                      }`}
                    >
                      {isPast ? (
                        <CheckCircle className="w-5 h-5 text-white" />
                      ) : (
                        <span className={`text-sm font-bold ${isActive ? "text-white" : "text-slate-500"}`}>
                          {index + 1}
                        </span>
                      )}
                    </div>

                    {/* Content */}
                    <div className="flex-1 space-y-2">
                      <div className="flex items-center gap-2">
                        <p className={`font-medium ${isPast ? "line-through text-slate-400" : "text-slate-800"}`}>
                          {step.instrumentName}
                        </p>
                        {step.type === "add" && (
                          <Badge className="bg-blue-100 text-blue-700 border-0 text-xs">Ajouter</Badge>
                        )}
                        {step.type === "remove" && (
                          <Badge className="bg-amber-100 text-amber-700 border-0 text-xs">Retirer</Badge>
                        )}
                        {step.type === "verify" && (
                          <Badge className="bg-indigo-100 text-indigo-700 border-0 text-xs">Vérifier</Badge>
                        )}
                      </div>
                      <p className="text-sm text-slate-500">{step.instruction}</p>
                      {step.position !== "—" && (
                        <p className="text-xs text-slate-400">Position : {step.position}</p>
                      )}

                      {isActive && !isPast && (
                        <Button
                          onClick={completeCurrentStep}
                          size="sm"
                          className="mt-2 bg-gradient-to-r from-emerald-500 to-emerald-600"
                          disabled={isValidating}
                        >
                          {isValidating ? (
                            <>
                              <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2" />
                              Validation en cours...
                            </>
                          ) : step.type === "verify" ? (
                            <>
                              <ScanLine className="w-4 h-4 mr-2" />
                              Valider par scan
                            </>
                          ) : (
                            <>
                              <CheckCircle className="w-4 h-4 mr-2" />
                              Marquer comme fait
                            </>
                          )}
                        </Button>
                      )}
                    </div>

                    {/* Checkbox for manual toggle */}
                    <Checkbox
                      checked={step.completed}
                      onCheckedChange={() => toggleStep(index)}
                      className="mt-1"
                    />
                  </div>
                </CardContent>
              </Card>
            )
          })}
        </div>

        {/* Right Panel - Kit Info */}
        <div className="space-y-6">
          <Card className="border-0 shadow-md">
            <CardHeader className="pb-3">
              <CardTitle className="text-base">Kit de Référence</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <p className="font-medium text-slate-800">{kit?.name}</p>
              <p className="text-sm text-slate-500">{kit?.description}</p>
              <div className="flex items-center gap-2 text-sm text-slate-600">
                <Package className="w-4 h-4" />
                {kit?.instruments.length} instruments
              </div>
              <div className="flex items-center gap-2 text-sm text-slate-600">
                <Wrench className="w-4 h-4" />
                {kit?.specialty}
              </div>
            </CardContent>
          </Card>

          <Card className="border-0 shadow-md bg-gradient-to-br from-indigo-50 to-blue-50">
            <CardContent className="p-5 space-y-3">
              <p className="font-medium text-indigo-800 text-sm">Résumé des Actions</p>
              <div className="space-y-2">
                {steps.filter((s) => s.type === "add").length > 0 && (
                  <div className="flex items-center gap-2 text-sm">
                    <ArrowDown className="w-4 h-4 text-blue-500" />
                    <span className="text-slate-700">
                      {steps.filter((s) => s.type === "add").length} instrument(s) à ajouter
                    </span>
                  </div>
                )}
                {steps.filter((s) => s.type === "remove").length > 0 && (
                  <div className="flex items-center gap-2 text-sm">
                    <XCircle className="w-4 h-4 text-amber-500" />
                    <span className="text-slate-700">
                      {steps.filter((s) => s.type === "remove").length} instrument(s) à retirer
                    </span>
                  </div>
                )}
                <div className="flex items-center gap-2 text-sm">
                  <ScanLine className="w-4 h-4 text-indigo-500" />
                  <span className="text-slate-700">1 validation finale par scan</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
