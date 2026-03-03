"use client"

import { useRouter } from "next/navigation"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { useAppContext } from "@/lib/app-context"
import { getConformityStats, getWeeklyScans } from "@/lib/mock-data"
import {
  ScanLine,
  CheckCircle,
  AlertTriangle,
  XCircle,
  Clock,
  Wifi,
  WifiOff,
  Upload,
  TrendingUp,
  Activity,
  ArrowRight,
} from "lucide-react"
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Cell,
} from "recharts"

export default function DashboardPage() {
  const router = useRouter()
  const { scanHistory, syncStatus } = useAppContext()
  const stats = getConformityStats()
  const weeklyData = getWeeklyScans()
  const recentScans = scanHistory.slice(0, 4)

  const statusConfig = {
    conforme: { color: "bg-emerald-500", text: "Conforme", icon: CheckCircle },
    partiel: { color: "bg-amber-500", text: "Partiel", icon: AlertTriangle },
    "non-conforme": { color: "bg-red-500", text: "Non conforme", icon: XCircle },
  }

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div className="ml-12 md:ml-0">
          <h1 className="text-2xl md:text-3xl font-bold text-slate-900">Tableau de Bord</h1>
          <p className="text-slate-500 mt-1">Vue d&apos;ensemble de la traçabilité des kits</p>
        </div>
        <div className="flex items-center gap-3">
          {/* Sync Status */}
          <div className="flex items-center gap-2 px-3 py-2 rounded-lg bg-white border shadow-sm text-sm">
            {syncStatus.isOnline ? (
              <Wifi className="w-4 h-4 text-emerald-500" />
            ) : (
              <WifiOff className="w-4 h-4 text-red-500" />
            )}
            <span className="text-slate-600">
              {syncStatus.isOnline ? "En ligne" : "Hors ligne"}
            </span>
            {syncStatus.pendingUploads > 0 && (
              <Badge variant="secondary" className="text-xs">
                <Upload className="w-3 h-3 mr-1" />
                {syncStatus.pendingUploads}
              </Badge>
            )}
          </div>
          <Button
            onClick={() => router.push("/scanner")}
            className="bg-gradient-to-r from-indigo-600 to-blue-600 hover:from-indigo-700 hover:to-blue-700 shadow-lg shadow-indigo-200"
          >
            <ScanLine className="w-4 h-4 mr-2" />
            Scanner un Kit
          </Button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <Card className="border-0 shadow-md bg-gradient-to-br from-indigo-500 to-indigo-600 text-white">
          <CardContent className="p-5">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-indigo-100 text-sm">Total Scans</p>
                <p className="text-3xl font-bold mt-1">{stats.total}</p>
              </div>
              <div className="w-12 h-12 rounded-xl bg-white/20 flex items-center justify-center">
                <Activity className="w-6 h-6" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-md bg-gradient-to-br from-emerald-500 to-emerald-600 text-white">
          <CardContent className="p-5">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-emerald-100 text-sm">Conformes</p>
                <p className="text-3xl font-bold mt-1">{stats.conforme}</p>
              </div>
              <div className="w-12 h-12 rounded-xl bg-white/20 flex items-center justify-center">
                <CheckCircle className="w-6 h-6" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-md bg-gradient-to-br from-red-500 to-red-600 text-white">
          <CardContent className="p-5">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-red-100 text-sm">Non conformes</p>
                <p className="text-3xl font-bold mt-1">{stats.nonConforme}</p>
              </div>
              <div className="w-12 h-12 rounded-xl bg-white/20 flex items-center justify-center">
                <XCircle className="w-6 h-6" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-md bg-gradient-to-br from-cyan-500 to-cyan-600 text-white">
          <CardContent className="p-5">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-cyan-100 text-sm">Score Moyen</p>
                <p className="text-3xl font-bold mt-1">{stats.avgScore}%</p>
              </div>
              <div className="w-12 h-12 rounded-xl bg-white/20 flex items-center justify-center">
                <TrendingUp className="w-6 h-6" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Chart + Recent Scans */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        {/* Weekly Chart */}
        <Card className="lg:col-span-3 border-0 shadow-md">
          <CardHeader className="pb-2">
            <CardTitle className="text-lg font-semibold text-slate-800">
              Activité Hebdomadaire
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={weeklyData} barGap={4}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="day" tick={{ fontSize: 12, fill: "#64748b" }} />
                  <YAxis tick={{ fontSize: 12, fill: "#64748b" }} />
                  <Tooltip
                    contentStyle={{
                      borderRadius: "12px",
                      border: "none",
                      boxShadow: "0 4px 20px rgba(0,0,0,0.1)",
                    }}
                  />
                  <Bar dataKey="scans" name="Total scans" radius={[6, 6, 0, 0]}>
                    {weeklyData.map((_, index) => (
                      <Cell key={`cell-${index}`} fill="#818cf8" />
                    ))}
                  </Bar>
                  <Bar dataKey="conformes" name="Conformes" radius={[6, 6, 0, 0]}>
                    {weeklyData.map((_, index) => (
                      <Cell key={`cell-c-${index}`} fill="#34d399" />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        {/* Conformity Breakdown */}
        <Card className="lg:col-span-2 border-0 shadow-md">
          <CardHeader className="pb-2">
            <CardTitle className="text-lg font-semibold text-slate-800">
              Répartition Conformité
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-5">
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-slate-600">Conformes</span>
                <span className="font-semibold text-emerald-600">{stats.conforme}/{stats.total}</span>
              </div>
              <Progress value={(stats.conforme / stats.total) * 100} className="h-3 bg-slate-100" />
            </div>
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-slate-600">Partiellement conformes</span>
                <span className="font-semibold text-amber-600">{stats.partiel}/{stats.total}</span>
              </div>
              <Progress value={(stats.partiel / stats.total) * 100} className="h-3 bg-slate-100" />
            </div>
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-slate-600">Non conformes</span>
                <span className="font-semibold text-red-600">{stats.nonConforme}/{stats.total}</span>
              </div>
              <Progress value={(stats.nonConforme / stats.total) * 100} className="h-3 bg-slate-100" />
            </div>

            <div className="pt-4 border-t">
              <div className="text-center">
                <p className="text-sm text-slate-500">Score moyen global</p>
                <p className="text-4xl font-bold text-indigo-600 mt-1">{stats.avgScore}%</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Recent Scans */}
      <Card className="border-0 shadow-md">
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-lg font-semibold text-slate-800">
            Derniers Scans
          </CardTitle>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => router.push("/historique")}
            className="text-indigo-600 hover:text-indigo-700"
          >
            Voir tout
            <ArrowRight className="w-4 h-4 ml-1" />
          </Button>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {recentScans.map((scan) => {
              const config = statusConfig[scan.status]
              const StatusIcon = config.icon
              return (
                <div
                  key={scan.id}
                  className="flex items-center justify-between p-4 rounded-xl bg-slate-50 hover:bg-slate-100 transition-colors cursor-pointer"
                  onClick={() => {
                    router.push("/resultats")
                  }}
                >
                  <div className="flex items-center gap-4">
                    <div className={`w-10 h-10 rounded-xl ${config.color} flex items-center justify-center`}>
                      <StatusIcon className="w-5 h-5 text-white" />
                    </div>
                    <div>
                      <p className="font-medium text-slate-800">{scan.kitReferenceName}</p>
                      <div className="flex items-center gap-2 mt-0.5">
                        <Clock className="w-3 h-3 text-slate-400" />
                        <span className="text-xs text-slate-500">
                          {new Date(scan.timestamp).toLocaleDateString("fr-FR", {
                            day: "numeric",
                            month: "short",
                            hour: "2-digit",
                            minute: "2-digit",
                          })}
                        </span>
                        <span className="text-xs text-slate-400">•</span>
                        <span className="text-xs text-slate-500">{scan.operator}</span>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <Badge
                      className={`${config.color} text-white border-0`}
                    >
                      {scan.conformityScore}%
                    </Badge>
                  </div>
                </div>
              )
            })}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
