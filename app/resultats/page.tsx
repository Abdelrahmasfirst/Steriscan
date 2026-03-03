"use client"

import { useRouter } from "next/navigation"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { useAppContext } from "@/lib/app-context"
import { scanHistory } from "@/lib/mock-data"
import {
  CheckCircle,
  XCircle,
  AlertTriangle,
  ArrowLeft,
  FileText,
  Wrench,
  Download,
  Clock,
  User,
  Package,
} from "lucide-react"

export default function ResultatsPage() {
  const router = useRouter()
  const { currentScan } = useAppContext()

  // Use current scan or fallback to first in history
  const scan = currentScan || scanHistory[0]

  if (!scan) {
    return (
      <div className="p-8 flex flex-col items-center justify-center min-h-[60vh] space-y-4">
        <Package className="w-16 h-16 text-slate-300" />
        <p className="text-slate-500 text-lg">Aucun résultat de scan disponible</p>
        <Button onClick={() => router.push("/scanner")}>Lancer un scan</Button>
      </div>
    )
  }

  const presentInstruments = scan.detectedInstruments.filter((i) => i.status === "present")
  const missingInstruments = scan.detectedInstruments.filter((i) => i.status === "missing")
  const extraInstruments = scan.detectedInstruments.filter((i) => i.status === "extra")

  const statusConfig = {
    conforme: { color: "bg-emerald-500", textColor: "text-emerald-700", bgLight: "bg-emerald-50", label: "Conforme", icon: CheckCircle },
    partiel: { color: "bg-amber-500", textColor: "text-amber-700", bgLight: "bg-amber-50", label: "Partiellement conforme", icon: AlertTriangle },
    "non-conforme": { color: "bg-red-500", textColor: "text-red-700", bgLight: "bg-red-50", label: "Non conforme", icon: XCircle },
  }

  const config = statusConfig[scan.status]
  const StatusIcon = config.icon

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-6xl mx-auto">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div className="flex items-center gap-3 ml-12 md:ml-0">
          <Button variant="ghost" size="icon" onClick={() => router.back()}>
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-slate-900">Résultats du Scan</h1>
            <p className="text-slate-500 mt-1">{scan.kitReferenceName}</p>
          </div>
        </div>
        <div className="flex gap-2 flex-wrap">
          <Button variant="outline" onClick={() => router.push("/comparaison")}>
            <FileText className="w-4 h-4 mr-2" />
            Comparer
          </Button>
          <Button
            onClick={() => router.push("/reconstitution")}
            className="bg-gradient-to-r from-indigo-600 to-blue-600"
          >
            <Wrench className="w-4 h-4 mr-2" />
            Reconstituer
          </Button>
        </div>
      </div>

      {/* Score Card */}
      <Card className={`border-0 shadow-md ${config.bgLight}`}>
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row items-center gap-6">
            {/* Score Circle */}
            <div className="relative w-32 h-32 shrink-0">
              <svg className="w-32 h-32 -rotate-90" viewBox="0 0 120 120">
                <circle cx="60" cy="60" r="52" fill="none" stroke="#e2e8f0" strokeWidth="10" />
                <circle
                  cx="60"
                  cy="60"
                  r="52"
                  fill="none"
                  stroke={scan.conformityScore >= 95 ? "#10b981" : scan.conformityScore >= 80 ? "#f59e0b" : "#ef4444"}
                  strokeWidth="10"
                  strokeLinecap="round"
                  strokeDasharray={`${(scan.conformityScore / 100) * 327} 327`}
                />
              </svg>
              <div className="absolute inset-0 flex flex-col items-center justify-center">
                <span className="text-3xl font-bold text-slate-800">{scan.conformityScore}%</span>
              </div>
            </div>

            <div className="flex-1 text-center md:text-left space-y-3">
              <div className="flex items-center gap-2 justify-center md:justify-start">
                <StatusIcon className={`w-6 h-6 ${config.textColor}`} />
                <span className={`text-xl font-bold ${config.textColor}`}>{config.label}</span>
              </div>
              <div className="flex flex-wrap gap-4 justify-center md:justify-start text-sm text-slate-600">
                <span className="flex items-center gap-1">
                  <Clock className="w-4 h-4" />
                  {new Date(scan.timestamp).toLocaleDateString("fr-FR", {
                    day: "numeric",
                    month: "long",
                    year: "numeric",
                    hour: "2-digit",
                    minute: "2-digit",
                  })}
                </span>
                <span className="flex items-center gap-1">
                  <User className="w-4 h-4" />
                  {scan.operator}
                </span>
              </div>
              {scan.notes && (
                <p className="text-sm text-slate-500 italic">&quot;{scan.notes}&quot;</p>
              )}
            </div>

            {/* Quick Stats */}
            <div className="flex gap-4 shrink-0">
              <div className="text-center px-4 py-2 rounded-xl bg-white shadow-sm">
                <p className="text-2xl font-bold text-emerald-600">{presentInstruments.length}</p>
                <p className="text-xs text-slate-500">Présents</p>
              </div>
              <div className="text-center px-4 py-2 rounded-xl bg-white shadow-sm">
                <p className="text-2xl font-bold text-red-600">{missingInstruments.length}</p>
                <p className="text-xs text-slate-500">Manquants</p>
              </div>
              <div className="text-center px-4 py-2 rounded-xl bg-white shadow-sm">
                <p className="text-2xl font-bold text-amber-600">{extraInstruments.length}</p>
                <p className="text-xs text-slate-500">En surplus</p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Instruments Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Present */}
        <Card className="border-0 shadow-md">
          <CardHeader className="pb-3">
            <CardTitle className="text-base flex items-center gap-2">
              <CheckCircle className="w-5 h-5 text-emerald-500" />
              Instruments Présents ({presentInstruments.length})
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2 max-h-80 overflow-y-auto pr-2">
              {presentInstruments.map((inst) => (
                <div
                  key={inst.id}
                  className="flex items-center justify-between p-3 rounded-lg bg-emerald-50 hover:bg-emerald-100 transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <CheckCircle className="w-4 h-4 text-emerald-500 shrink-0" />
                    <div>
                      <p className="text-sm font-medium text-slate-800">{inst.name}</p>
                      <p className="text-xs text-slate-500">ID: {inst.instrumentId}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-semibold text-emerald-600">
                      {inst.confidence.toFixed(1)}%
                    </p>
                    <Progress
                      value={inst.confidence}
                      className="h-1 w-16 mt-1"
                    />
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Missing & Extra */}
        <div className="space-y-6">
          {missingInstruments.length > 0 && (
            <Card className="border-0 shadow-md border-l-4 border-l-red-500">
              <CardHeader className="pb-3">
                <CardTitle className="text-base flex items-center gap-2">
                  <XCircle className="w-5 h-5 text-red-500" />
                  Instruments Manquants ({missingInstruments.length})
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  {missingInstruments.map((inst) => (
                    <div
                      key={inst.id}
                      className="flex items-center justify-between p-3 rounded-lg bg-red-50"
                    >
                      <div className="flex items-center gap-3">
                        <XCircle className="w-4 h-4 text-red-500 shrink-0" />
                        <div>
                          <p className="text-sm font-medium text-slate-800">{inst.name}</p>
                          <p className="text-xs text-slate-500">ID: {inst.instrumentId}</p>
                        </div>
                      </div>
                      <Badge variant="destructive" className="text-xs">
                        Manquant
                      </Badge>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}

          {extraInstruments.length > 0 && (
            <Card className="border-0 shadow-md border-l-4 border-l-amber-500">
              <CardHeader className="pb-3">
                <CardTitle className="text-base flex items-center gap-2">
                  <AlertTriangle className="w-5 h-5 text-amber-500" />
                  Instruments en Surplus ({extraInstruments.length})
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  {extraInstruments.map((inst) => (
                    <div
                      key={inst.id}
                      className="flex items-center justify-between p-3 rounded-lg bg-amber-50"
                    >
                      <div className="flex items-center gap-3">
                        <AlertTriangle className="w-4 h-4 text-amber-500 shrink-0" />
                        <div>
                          <p className="text-sm font-medium text-slate-800">{inst.name}</p>
                          <p className="text-xs text-slate-500">ID: {inst.instrumentId}</p>
                        </div>
                      </div>
                      <Badge className="bg-amber-500 text-white border-0 text-xs">
                        Surplus
                      </Badge>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}

          {missingInstruments.length === 0 && extraInstruments.length === 0 && (
            <Card className="border-0 shadow-md bg-emerald-50">
              <CardContent className="p-8 text-center">
                <CheckCircle className="w-12 h-12 text-emerald-500 mx-auto mb-3" />
                <p className="font-medium text-emerald-700">Aucune anomalie détectée</p>
                <p className="text-sm text-emerald-600 mt-1">
                  Tous les instruments sont conformes à la référence
                </p>
              </CardContent>
            </Card>
          )}
        </div>
      </div>

      {/* Actions */}
      <Card className="border-0 shadow-md">
        <CardContent className="p-4">
          <div className="flex flex-wrap gap-3 justify-end">
            <Button variant="outline">
              <Download className="w-4 h-4 mr-2" />
              Exporter PDF
            </Button>
            <Button variant="outline">
              <Download className="w-4 h-4 mr-2" />
              Exporter CSV
            </Button>
            <Button
              onClick={() => router.push("/scanner")}
              variant="outline"
            >
              Nouveau Scan
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
