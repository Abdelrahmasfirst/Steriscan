"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { useAppContext } from "@/lib/app-context"
import { getConformityStats } from "@/lib/mock-data"
import {
  History,
  Search,
  Filter,
  CheckCircle,
  XCircle,
  AlertTriangle,
  Clock,
  User,
  Download,
  FileText,
  BarChart3,
  TrendingUp,
  Calendar,
  Eye,
} from "lucide-react"
import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Tooltip,
  Legend,
} from "recharts"

export default function HistoriquePage() {
  const router = useRouter()
  const { scanHistory, setCurrentScan } = useAppContext()
  const stats = getConformityStats()

  const [searchQuery, setSearchQuery] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("all")
  const [sortOrder, setSortOrder] = useState<string>("newest")

  // Filter and sort
  let filtered = scanHistory.filter((scan) => {
    const matchesSearch =
      scan.kitReferenceName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      scan.operator.toLowerCase().includes(searchQuery.toLowerCase()) ||
      scan.id.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesStatus = statusFilter === "all" || scan.status === statusFilter
    return matchesSearch && matchesStatus
  })

  if (sortOrder === "oldest") {
    filtered = [...filtered].reverse()
  } else if (sortOrder === "score-high") {
    filtered = [...filtered].sort((a, b) => b.conformityScore - a.conformityScore)
  } else if (sortOrder === "score-low") {
    filtered = [...filtered].sort((a, b) => a.conformityScore - b.conformityScore)
  }

  const statusConfig = {
    conforme: { color: "bg-emerald-500", text: "Conforme", icon: CheckCircle, chartColor: "#10b981" },
    partiel: { color: "bg-amber-500", text: "Partiel", icon: AlertTriangle, chartColor: "#f59e0b" },
    "non-conforme": { color: "bg-red-500", text: "Non conforme", icon: XCircle, chartColor: "#ef4444" },
  }

  const pieData = [
    { name: "Conformes", value: stats.conforme, color: "#10b981" },
    { name: "Partiels", value: stats.partiel, color: "#f59e0b" },
    { name: "Non conformes", value: stats.nonConforme, color: "#ef4444" },
  ]

  const viewScan = (scan: typeof scanHistory[0]) => {
    setCurrentScan(scan)
    router.push("/resultats")
  }

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div className="ml-12 md:ml-0">
          <h1 className="text-2xl md:text-3xl font-bold text-slate-900">Historique & Rapports</h1>
          <p className="text-slate-500 mt-1">Journal complet des scans et statistiques</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline">
            <Download className="w-4 h-4 mr-2" />
            Export PDF
          </Button>
          <Button variant="outline">
            <FileText className="w-4 h-4 mr-2" />
            Export CSV
          </Button>
        </div>
      </div>

      {/* Stats Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Pie Chart */}
        <Card className="border-0 shadow-md">
          <CardHeader className="pb-0">
            <CardTitle className="text-base flex items-center gap-2">
              <BarChart3 className="w-4 h-4 text-indigo-600" />
              Répartition
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-48">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={pieData}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={75}
                    paddingAngle={4}
                    dataKey="value"
                  >
                    {pieData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend
                    verticalAlign="bottom"
                    height={36}
                    formatter={(value) => <span className="text-xs text-slate-600">{value}</span>}
                  />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        {/* Quick Stats */}
        <Card className="border-0 shadow-md lg:col-span-2">
          <CardHeader className="pb-2">
            <CardTitle className="text-base flex items-center gap-2">
              <TrendingUp className="w-4 h-4 text-indigo-600" />
              Statistiques Clés
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="p-4 rounded-xl bg-slate-50 text-center">
                <p className="text-3xl font-bold text-indigo-600">{stats.total}</p>
                <p className="text-xs text-slate-500 mt-1">Total scans</p>
              </div>
              <div className="p-4 rounded-xl bg-emerald-50 text-center">
                <p className="text-3xl font-bold text-emerald-600">{stats.avgScore}%</p>
                <p className="text-xs text-slate-500 mt-1">Score moyen</p>
              </div>
              <div className="p-4 rounded-xl bg-emerald-50 text-center">
                <p className="text-3xl font-bold text-emerald-600">
                  {Math.round((stats.conforme / stats.total) * 100)}%
                </p>
                <p className="text-xs text-slate-500 mt-1">Taux conformité</p>
              </div>
              <div className="p-4 rounded-xl bg-red-50 text-center">
                <p className="text-3xl font-bold text-red-600">
                  {scanHistory.reduce((sum, s) => sum + s.missingCount, 0)}
                </p>
                <p className="text-xs text-slate-500 mt-1">Instruments manquants</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Filters */}
      <Card className="border-0 shadow-md">
        <CardContent className="p-4">
          <div className="flex flex-col md:flex-row gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
              <Input
                placeholder="Rechercher par kit, opérateur, ID..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>
            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger className="w-full md:w-48">
                <Filter className="w-4 h-4 mr-2" />
                <SelectValue placeholder="Statut" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">Tous les statuts</SelectItem>
                <SelectItem value="conforme">Conforme</SelectItem>
                <SelectItem value="partiel">Partiel</SelectItem>
                <SelectItem value="non-conforme">Non conforme</SelectItem>
              </SelectContent>
            </Select>
            <Select value={sortOrder} onValueChange={setSortOrder}>
              <SelectTrigger className="w-full md:w-48">
                <SelectValue placeholder="Trier par" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="newest">Plus récent</SelectItem>
                <SelectItem value="oldest">Plus ancien</SelectItem>
                <SelectItem value="score-high">Score (haut)</SelectItem>
                <SelectItem value="score-low">Score (bas)</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Scan List */}
      <Card className="border-0 shadow-md">
        <CardHeader className="pb-2">
          <CardTitle className="text-base flex items-center gap-2">
            <History className="w-4 h-4 text-indigo-600" />
            Journal des Scans ({filtered.length})
          </CardTitle>
        </CardHeader>
        <CardContent>
          {filtered.length === 0 ? (
            <div className="text-center py-12">
              <Search className="w-12 h-12 text-slate-300 mx-auto mb-3" />
              <p className="text-slate-500">Aucun scan trouvé</p>
            </div>
          ) : (
            <div className="space-y-3">
              {filtered.map((scan) => {
                const config = statusConfig[scan.status]
                const StatusIcon = config.icon

                return (
                  <div
                    key={scan.id}
                    className="flex flex-col md:flex-row md:items-center justify-between p-4 rounded-xl bg-slate-50 hover:bg-slate-100 transition-colors gap-3"
                  >
                    <div className="flex items-center gap-4">
                      <div className={`w-10 h-10 rounded-xl ${config.color} flex items-center justify-center shrink-0`}>
                        <StatusIcon className="w-5 h-5 text-white" />
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <p className="font-medium text-slate-800">{scan.kitReferenceName}</p>
                          <Badge variant="outline" className="text-xs">
                            {scan.id}
                          </Badge>
                        </div>
                        <div className="flex flex-wrap items-center gap-3 mt-1 text-xs text-slate-500">
                          <span className="flex items-center gap-1">
                            <Calendar className="w-3 h-3" />
                            {new Date(scan.timestamp).toLocaleDateString("fr-FR", {
                              day: "numeric",
                              month: "short",
                              year: "numeric",
                              hour: "2-digit",
                              minute: "2-digit",
                            })}
                          </span>
                          <span className="flex items-center gap-1">
                            <User className="w-3 h-3" />
                            {scan.operator}
                          </span>
                          {scan.missingCount > 0 && (
                            <span className="text-red-500">
                              {scan.missingCount} manquant(s)
                            </span>
                          )}
                          {scan.extraCount > 0 && (
                            <span className="text-amber-500">
                              {scan.extraCount} surplus
                            </span>
                          )}
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center gap-3 ml-14 md:ml-0">
                      <Badge className={`${config.color} text-white border-0`}>
                        {scan.conformityScore}%
                      </Badge>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => viewScan(scan)}
                        className="text-indigo-600"
                      >
                        <Eye className="w-4 h-4 mr-1" />
                        Détails
                      </Button>
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
