"use client"

import { useRouter } from "next/navigation"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { useAppContext } from "@/lib/app-context"
import { scanHistory, kitReferences } from "@/lib/mock-data"
import {
  ArrowLeft,
  CheckCircle,
  XCircle,
  AlertTriangle,
  ArrowLeftRight,
  Package,
  Wrench,
} from "lucide-react"

export default function ComparaisonPage() {
  const router = useRouter()
  const { currentScan } = useAppContext()

  const scan = currentScan || scanHistory[0]

  if (!scan) {
    return (
      <div className="p-8 flex flex-col items-center justify-center min-h-[60vh] space-y-4">
        <Package className="w-16 h-16 text-slate-300" />
        <p className="text-slate-500 text-lg">Aucun scan à comparer</p>
        <Button onClick={() => router.push("/scanner")}>Lancer un scan</Button>
      </div>
    )
  }

  const kit = kitReferences.find((k) => k.id === scan.kitReferenceId)
  const referenceInstruments = kit?.instruments || []

  // Build comparison map
  const comparisonItems = referenceInstruments.map((refInst) => {
    const detected = scan.detectedInstruments.find(
      (d) => d.instrumentId === refInst.id && d.status !== "extra"
    )
    return {
      id: refInst.id,
      name: refInst.name,
      category: refInst.category,
      inReference: true,
      inScan: detected?.status === "present",
      status: detected?.status || "missing",
      confidence: detected?.confidence || 0,
    }
  })

  const extraItems = scan.detectedInstruments
    .filter((d) => d.status === "extra")
    .map((d) => ({
      id: d.instrumentId,
      name: d.name,
      category: "—",
      inReference: false,
      inScan: true,
      status: "extra" as const,
      confidence: d.confidence,
    }))

  const allItems = [...comparisonItems, ...extraItems]
  const presentCount = comparisonItems.filter((i) => i.status === "present").length
  const missingCount = comparisonItems.filter((i) => i.status === "missing").length
  const extraCount = extraItems.length

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-6xl mx-auto">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div className="flex items-center gap-3 ml-12 md:ml-0">
          <Button variant="ghost" size="icon" onClick={() => router.back()}>
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-slate-900">Comparaison & Alertes</h1>
            <p className="text-slate-500 mt-1">Référence vs Scan actuel</p>
          </div>
        </div>
        <Button
          onClick={() => router.push("/reconstitution")}
          className="bg-gradient-to-r from-indigo-600 to-blue-600"
        >
          <Wrench className="w-4 h-4 mr-2" />
          Reconstituer le Kit
        </Button>
      </div>

      {/* Summary */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card className="border-0 shadow-md bg-emerald-50">
          <CardContent className="p-5 flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-emerald-500 flex items-center justify-center">
              <CheckCircle className="w-6 h-6 text-white" />
            </div>
            <div>
              <p className="text-2xl font-bold text-emerald-700">{presentCount}</p>
              <p className="text-sm text-emerald-600">Instruments conformes</p>
            </div>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-md bg-red-50">
          <CardContent className="p-5 flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-red-500 flex items-center justify-center">
              <XCircle className="w-6 h-6 text-white" />
            </div>
            <div>
              <p className="text-2xl font-bold text-red-700">{missingCount}</p>
              <p className="text-sm text-red-600">Instruments manquants</p>
            </div>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-md bg-amber-50">
          <CardContent className="p-5 flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-amber-500 flex items-center justify-center">
              <AlertTriangle className="w-6 h-6 text-white" />
            </div>
            <div>
              <p className="text-2xl font-bold text-amber-700">{extraCount}</p>
              <p className="text-sm text-amber-600">Instruments en surplus</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Comparison Table */}
      <Card className="border-0 shadow-md">
        <CardHeader>
          <CardTitle className="text-lg flex items-center gap-2">
            <ArrowLeftRight className="w-5 h-5 text-indigo-600" />
            Vue Comparative Détaillée
          </CardTitle>
        </CardHeader>
        <CardContent>
          {/* Table Header */}
          <div className="hidden md:grid grid-cols-12 gap-4 px-4 py-3 bg-slate-100 rounded-t-xl text-sm font-medium text-slate-600">
            <div className="col-span-4">Instrument</div>
            <div className="col-span-2 text-center">Référence</div>
            <div className="col-span-2 text-center">Scan Actuel</div>
            <div className="col-span-2 text-center">Confiance</div>
            <div className="col-span-2 text-center">Statut</div>
          </div>

          {/* Table Body */}
          <div className="divide-y">
            {allItems.map((item) => {
              const rowBg =
                item.status === "missing"
                  ? "bg-red-50 hover:bg-red-100"
                  : item.status === "extra"
                  ? "bg-amber-50 hover:bg-amber-100"
                  : "hover:bg-slate-50"

              return (
                <div
                  key={`${item.id}-${item.status}`}
                  className={`grid grid-cols-1 md:grid-cols-12 gap-2 md:gap-4 px-4 py-4 transition-colors ${rowBg}`}
                >
                  {/* Instrument Name */}
                  <div className="md:col-span-4 flex items-center gap-3">
                    {item.status === "present" && <CheckCircle className="w-4 h-4 text-emerald-500 shrink-0" />}
                    {item.status === "missing" && <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                    {item.status === "extra" && <AlertTriangle className="w-4 h-4 text-amber-500 shrink-0" />}
                    <div>
                      <p className="font-medium text-slate-800 text-sm">{item.name}</p>
                      <p className="text-xs text-slate-500">{item.category}</p>
                    </div>
                  </div>

                  {/* Reference */}
                  <div className="md:col-span-2 flex items-center justify-center">
                    {item.inReference ? (
                      <Badge className="bg-indigo-100 text-indigo-700 border-0 text-xs">
                        Attendu
                      </Badge>
                    ) : (
                      <span className="text-xs text-slate-400">—</span>
                    )}
                  </div>

                  {/* Scan */}
                  <div className="md:col-span-2 flex items-center justify-center">
                    {item.inScan ? (
                      <Badge className="bg-blue-100 text-blue-700 border-0 text-xs">
                        Détecté
                      </Badge>
                    ) : (
                      <Badge variant="outline" className="text-red-500 border-red-200 text-xs">
                        Non détecté
                      </Badge>
                    )}
                  </div>

                  {/* Confidence */}
                  <div className="md:col-span-2 flex items-center justify-center">
                    {item.confidence > 0 ? (
                      <span
                        className={`text-sm font-semibold ${
                          item.confidence >= 95
                            ? "text-emerald-600"
                            : item.confidence >= 85
                            ? "text-amber-600"
                            : "text-red-600"
                        }`}
                      >
                        {item.confidence.toFixed(1)}%
                      </span>
                    ) : (
                      <span className="text-xs text-slate-400">—</span>
                    )}
                  </div>

                  {/* Status */}
                  <div className="md:col-span-2 flex items-center justify-center">
                    {item.status === "present" && (
                      <Badge className="bg-emerald-500 text-white border-0 text-xs">
                        Conforme
                      </Badge>
                    )}
                    {item.status === "missing" && (
                      <Badge className="bg-red-500 text-white border-0 text-xs">
                        Manquant
                      </Badge>
                    )}
                    {item.status === "extra" && (
                      <Badge className="bg-amber-500 text-white border-0 text-xs">
                        Surplus
                      </Badge>
                    )}
                  </div>
                </div>
              )
            })}
          </div>
        </CardContent>
      </Card>

      {/* Alerts */}
      {(missingCount > 0 || extraCount > 0) && (
        <Card className="border-0 shadow-md border-l-4 border-l-red-500 bg-red-50">
          <CardContent className="p-6">
            <div className="flex items-start gap-4">
              <div className="w-10 h-10 rounded-xl bg-red-500 flex items-center justify-center shrink-0">
                <AlertTriangle className="w-5 h-5 text-white" />
              </div>
              <div className="space-y-2">
                <p className="font-bold text-red-800">Alerte de Non-Conformité</p>
                <p className="text-sm text-red-700">
                  Le kit scanné présente des anomalies par rapport à la composition de référence.
                  {missingCount > 0 && ` ${missingCount} instrument(s) manquant(s).`}
                  {extraCount > 0 && ` ${extraCount} instrument(s) en surplus.`}
                </p>
                <p className="text-sm text-red-600">
                  Action recommandée : Procéder à la reconstitution guidée du kit.
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
