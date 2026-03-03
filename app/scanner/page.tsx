"use client"

import { useState, useRef } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { useAppContext } from "@/lib/app-context"
import { kitReferences, instrumentsDatabase } from "@/lib/mock-data"
import type { ScanResult, DetectedInstrument } from "@/lib/types"
import { toast } from "sonner"
import {
  Camera,
  Upload,
  Zap,
  Target,
  Image as ImageIcon,
  RotateCcw,
  ScanLine,
  CheckCircle,
  Crosshair,
} from "lucide-react"

export default function ScannerPage() {
  const router = useRouter()
  const { addScanResult, setCurrentScan } = useAppContext()
  const fileInputRef = useRef<HTMLInputElement>(null)

  const [selectedImage, setSelectedImage] = useState<string | null>(null)
  const [selectedKit, setSelectedKit] = useState<string>("")
  const [isScanning, setIsScanning] = useState(false)
  const [scanProgress, setScanProgress] = useState(0)
  const [scanPhase, setScanPhase] = useState("")

  const handleImageUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        setSelectedImage(e.target?.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const simulateScan = async () => {
    if (!selectedKit) {
      toast.error("Veuillez sélectionner un kit de référence")
      return
    }

    setIsScanning(true)
    setScanProgress(0)

    const phases = [
      { text: "Prétraitement de l'image...", progress: 15 },
      { text: "Détection des contours...", progress: 30 },
      { text: "Segmentation des instruments...", progress: 50 },
      { text: "Classification YOLOv7...", progress: 70 },
      { text: "Calcul des scores de confiance...", progress: 85 },
      { text: "Comparaison avec la référence...", progress: 95 },
      { text: "Génération du rapport...", progress: 100 },
    ]

    for (const phase of phases) {
      setScanPhase(phase.text)
      setScanProgress(phase.progress)
      await new Promise((r) => setTimeout(r, 500 + Math.random() * 400))
    }

    // Generate mock results
    const kit = kitReferences.find((k) => k.id === selectedKit)!
    const detected: DetectedInstrument[] = kit.instruments.map((inst, idx) => {
      const rand = Math.random()
      let status: "present" | "missing" | "extra" = "present"
      if (rand < 0.1) status = "missing"

      return {
        id: `DET-NEW-${idx}`,
        instrumentId: inst.id,
        name: inst.name,
        status,
        confidence: status === "missing" ? 0 : 88 + Math.random() * 11,
        position: { x: 40 + (idx % 5) * 130, y: 60 + Math.floor(idx / 5) * 110 },
      }
    })

    // Maybe add an extra
    if (Math.random() > 0.6) {
      const extraInst = instrumentsDatabase.find(
        (i) => !kit.instruments.some((ki) => ki.id === i.id)
      )
      if (extraInst) {
        detected.push({
          id: "DET-NEW-EXTRA",
          instrumentId: extraInst.id,
          name: extraInst.name,
          status: "extra",
          confidence: 85 + Math.random() * 10,
          position: { x: 500, y: 300 },
        })
      }
    }

    const missingCount = detected.filter((d) => d.status === "missing").length
    const extraCount = detected.filter((d) => d.status === "extra").length
    const presentCount = detected.filter((d) => d.status === "present").length
    const score = Math.round((presentCount / kit.instruments.length) * 100)

    const result: ScanResult = {
      id: `SCAN-${Date.now()}`,
      kitReferenceId: kit.id,
      kitReferenceName: kit.name,
      timestamp: new Date().toISOString(),
      status: score >= 95 ? "conforme" : score >= 80 ? "partiel" : "non-conforme",
      conformityScore: score,
      detectedInstruments: detected,
      missingCount,
      extraCount,
      operator: "Aminata Diallo",
      imageUrl: selectedImage || undefined,
    }

    addScanResult(result)
    setCurrentScan(result)
    setIsScanning(false)

    toast.success("Scan terminé avec succès !")
    router.push("/resultats")
  }

  const resetScan = () => {
    setSelectedImage(null)
    setSelectedKit("")
    setScanProgress(0)
    setScanPhase("")
    if (fileInputRef.current) fileInputRef.current.value = ""
  }

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-5xl mx-auto">
      {/* Header */}
      <div className="ml-12 md:ml-0">
        <h1 className="text-2xl md:text-3xl font-bold text-slate-900">Scanner & Capture</h1>
        <p className="text-slate-500 mt-1">Analysez un kit d&apos;instruments chirurgicaux par IA</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left: Image capture */}
        <div className="lg:col-span-2 space-y-6">
          <Card className="border-0 shadow-md overflow-hidden">
            <CardHeader className="bg-gradient-to-r from-indigo-600 to-blue-600 text-white">
              <CardTitle className="flex items-center gap-2 text-lg">
                <Camera className="w-5 h-5" />
                Zone de Capture
              </CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              {selectedImage ? (
                <div className="relative">
                  <img
                    src={selectedImage}
                    alt="Kit scanné"
                    className="w-full h-80 object-contain bg-slate-900"
                  />
                  {/* Overlay grid */}
                  <div className="absolute inset-0 pointer-events-none">
                    <div className="absolute top-4 left-4 w-16 h-16 border-l-2 border-t-2 border-cyan-400 opacity-60" />
                    <div className="absolute top-4 right-4 w-16 h-16 border-r-2 border-t-2 border-cyan-400 opacity-60" />
                    <div className="absolute bottom-4 left-4 w-16 h-16 border-l-2 border-b-2 border-cyan-400 opacity-60" />
                    <div className="absolute bottom-4 right-4 w-16 h-16 border-r-2 border-b-2 border-cyan-400 opacity-60" />
                    <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
                      <Crosshair className="w-8 h-8 text-cyan-400 opacity-40" />
                    </div>
                  </div>
                  {/* Status badge */}
                  <div className="absolute top-3 right-3">
                    <Badge className="bg-emerald-500 text-white border-0">
                      <CheckCircle className="w-3 h-3 mr-1" />
                      Image chargée
                    </Badge>
                  </div>
                </div>
              ) : (
                <div className="h-80 flex flex-col items-center justify-center bg-gradient-to-b from-slate-50 to-slate-100 space-y-4">
                  <div className="w-20 h-20 rounded-2xl bg-indigo-100 flex items-center justify-center">
                    <ImageIcon className="w-10 h-10 text-indigo-400" />
                  </div>
                  <div className="text-center">
                    <p className="font-medium text-slate-700">Aucune image sélectionnée</p>
                    <p className="text-sm text-slate-500 mt-1">
                      Importez une photo du kit à analyser
                    </p>
                  </div>
                </div>
              )}

              <div className="p-4 flex flex-wrap gap-3 border-t">
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  onChange={handleImageUpload}
                  className="hidden"
                  id="image-upload"
                />
                <Button
                  variant="outline"
                  onClick={() => fileInputRef.current?.click()}
                  className="flex-1"
                >
                  <Upload className="w-4 h-4 mr-2" />
                  Importer une image
                </Button>
                <Button
                  variant="outline"
                  onClick={() => {
                    setSelectedImage("/placeholder.svg")
                    toast.info("Image de démonstration chargée")
                  }}
                  className="flex-1"
                >
                  <Camera className="w-4 h-4 mr-2" />
                  Photo démo
                </Button>
                {selectedImage && (
                  <Button variant="ghost" onClick={resetScan} size="icon">
                    <RotateCcw className="w-4 h-4" />
                  </Button>
                )}
              </div>
            </CardContent>
          </Card>

          {/* Scan Progress */}
          {isScanning && (
            <Card className="border-0 shadow-md border-l-4 border-l-indigo-500">
              <CardContent className="p-6 space-y-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-indigo-100 flex items-center justify-center">
                    <Zap className="w-5 h-5 text-indigo-600 animate-pulse" />
                  </div>
                  <div className="flex-1">
                    <p className="font-medium text-slate-800">Analyse IA en cours</p>
                    <p className="text-sm text-indigo-600">{scanPhase}</p>
                  </div>
                  <span className="text-lg font-bold text-indigo-600">{scanProgress}%</span>
                </div>
                <Progress value={scanProgress} className="h-2" />
              </CardContent>
            </Card>
          )}
        </div>

        {/* Right: Controls */}
        <div className="space-y-6">
          {/* Kit Selection */}
          <Card className="border-0 shadow-md">
            <CardHeader>
              <CardTitle className="text-base flex items-center gap-2">
                <Target className="w-4 h-4 text-indigo-600" />
                Kit de Référence
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <Select value={selectedKit} onValueChange={setSelectedKit}>
                <SelectTrigger>
                  <SelectValue placeholder="Sélectionner un kit..." />
                </SelectTrigger>
                <SelectContent>
                  {kitReferences.map((kit) => (
                    <SelectItem key={kit.id} value={kit.id}>
                      <div>
                        <p className="font-medium">{kit.name}</p>
                        <p className="text-xs text-slate-500">{kit.specialty} • {kit.instruments.length} instruments</p>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              {selectedKit && (
                <div className="p-3 rounded-lg bg-indigo-50 space-y-2">
                  <p className="text-sm font-medium text-indigo-800">
                    {kitReferences.find((k) => k.id === selectedKit)?.name}
                  </p>
                  <p className="text-xs text-indigo-600">
                    {kitReferences.find((k) => k.id === selectedKit)?.instruments.length} instruments attendus
                  </p>
                  <p className="text-xs text-slate-500">
                    {kitReferences.find((k) => k.id === selectedKit)?.description}
                  </p>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Scan Button */}
          <Card className="border-0 shadow-md">
            <CardContent className="p-6">
              <Button
                onClick={simulateScan}
                disabled={isScanning || !selectedImage}
                className="w-full h-14 text-lg bg-gradient-to-r from-emerald-500 to-emerald-600 hover:from-emerald-600 hover:to-emerald-700 shadow-lg shadow-emerald-200 disabled:opacity-50"
              >
                {isScanning ? (
                  <>
                    <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2" />
                    Analyse en cours...
                  </>
                ) : (
                  <>
                    <ScanLine className="w-5 h-5 mr-2" />
                    Démarrer le Scan IA
                  </>
                )}
              </Button>
              {!selectedImage && (
                <p className="text-xs text-center text-slate-400 mt-3">
                  Importez une image pour activer le scan
                </p>
              )}
            </CardContent>
          </Card>

          {/* Tips */}
          <Card className="border-0 shadow-md bg-gradient-to-br from-amber-50 to-orange-50">
            <CardContent className="p-5 space-y-3">
              <p className="font-medium text-amber-800 text-sm">Conseils pour un bon scan</p>
              <ul className="space-y-2 text-xs text-amber-700">
                <li className="flex items-start gap-2">
                  <span className="mt-0.5 w-1.5 h-1.5 rounded-full bg-amber-400 shrink-0" />
                  Éclairage uniforme sans ombres portées
                </li>
                <li className="flex items-start gap-2">
                  <span className="mt-0.5 w-1.5 h-1.5 rounded-full bg-amber-400 shrink-0" />
                  Instruments bien espacés et visibles
                </li>
                <li className="flex items-start gap-2">
                  <span className="mt-0.5 w-1.5 h-1.5 rounded-full bg-amber-400 shrink-0" />
                  Fond contrasté (drap bleu recommandé)
                </li>
                <li className="flex items-start gap-2">
                  <span className="mt-0.5 w-1.5 h-1.5 rounded-full bg-amber-400 shrink-0" />
                  Photo prise à 40-60cm de hauteur
                </li>
              </ul>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
