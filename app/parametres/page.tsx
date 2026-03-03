"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"
import { Slider } from "@/components/ui/slider"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { useAppContext } from "@/lib/app-context"
import { toast } from "sonner"
import {
  Settings,
  Globe,
  Bell,
  Smartphone,
  Database,
  Shield,
  Download,
  Upload,
  Wifi,
  WifiOff,
  Volume2,
  VolumeX,
  Save,
  RotateCcw,
  Info,
  Server,
  Lock,
} from "lucide-react"

export default function ParametresPage() {
  const { settings, updateSettings, syncStatus } = useAppContext()

  const [localSettings, setLocalSettings] = useState(settings)

  const updateLocal = (key: string, value: any) => {
    setLocalSettings((prev: any) => ({ ...prev, [key]: value }))
  }

  const saveSettings = () => {
    updateSettings(localSettings)
    toast.success("Paramètres sauvegardés avec succès")
  }

  const resetSettings = () => {
    const defaults = {
      language: "fr" as const,
      smsAlertsEnabled: false,
      smsPhoneNumber: "",
      offlineMode: true,
      autoSync: false,
      soundAlerts: true,
      confidenceThreshold: 90,
    }
    setLocalSettings(defaults)
    updateSettings(defaults)
    toast.info("Paramètres réinitialisés")
  }

  const languageLabels: Record<string, string> = {
    fr: "Français",
    sw: "Kiswahili",
    ha: "Haoussa",
  }

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-4xl mx-auto">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div className="ml-12 md:ml-0">
          <h1 className="text-2xl md:text-3xl font-bold text-slate-900">Paramètres</h1>
          <p className="text-slate-500 mt-1">Configuration de l&apos;application</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={resetSettings}>
            <RotateCcw className="w-4 h-4 mr-2" />
            Réinitialiser
          </Button>
          <Button
            onClick={saveSettings}
            className="bg-gradient-to-r from-indigo-600 to-blue-600"
          >
            <Save className="w-4 h-4 mr-2" />
            Sauvegarder
          </Button>
        </div>
      </div>

      {/* Language */}
      <Card className="border-0 shadow-md">
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <Globe className="w-5 h-5 text-indigo-600" />
            Langue & Localisation
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label>Langue de l&apos;interface</Label>
            <Select
              value={localSettings.language}
              onValueChange={(val) => updateLocal("language", val)}
            >
              <SelectTrigger className="w-full md:w-64">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="fr">Français</SelectItem>
                <SelectItem value="sw">Kiswahili</SelectItem>
                <SelectItem value="ha">Haoussa</SelectItem>
              </SelectContent>
            </Select>
            <p className="text-xs text-slate-500">
              Langue actuelle : {languageLabels[localSettings.language]}
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Alerts */}
      <Card className="border-0 shadow-md">
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <Bell className="w-5 h-5 text-indigo-600" />
            Alertes & Notifications
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="flex items-center justify-between">
            <div className="space-y-1">
              <Label className="flex items-center gap-2">
                {localSettings.soundAlerts ? (
                  <Volume2 className="w-4 h-4 text-indigo-500" />
                ) : (
                  <VolumeX className="w-4 h-4 text-slate-400" />
                )}
                Alertes sonores
              </Label>
              <p className="text-xs text-slate-500">
                Son lors de la détection d&apos;anomalies
              </p>
            </div>
            <Switch
              checked={localSettings.soundAlerts}
              onCheckedChange={(val) => updateLocal("soundAlerts", val)}
            />
          </div>

          <Separator />

          <div className="flex items-center justify-between">
            <div className="space-y-1">
              <Label className="flex items-center gap-2">
                <Smartphone className="w-4 h-4 text-indigo-500" />
                Alertes SMS (GSM)
              </Label>
              <p className="text-xs text-slate-500">
                Envoyer des alertes par SMS via réseau GSM
              </p>
            </div>
            <Switch
              checked={localSettings.smsAlertsEnabled}
              onCheckedChange={(val) => updateLocal("smsAlertsEnabled", val)}
            />
          </div>

          {localSettings.smsAlertsEnabled && (
            <div className="ml-6 space-y-2">
              <Label>Numéro de téléphone</Label>
              <Input
                placeholder="+225 XX XX XX XX XX"
                value={localSettings.smsPhoneNumber}
                onChange={(e) => updateLocal("smsPhoneNumber", e.target.value)}
                className="w-full md:w-64"
              />
              <p className="text-xs text-slate-500">
                Format international avec indicatif pays
              </p>
            </div>
          )}
        </CardContent>
      </Card>

      {/* AI Configuration */}
      <Card className="border-0 shadow-md">
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <Settings className="w-5 h-5 text-indigo-600" />
            Configuration IA
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <Label>Seuil de confiance minimum</Label>
              <Badge variant="outline" className="font-mono">
                {localSettings.confidenceThreshold}%
              </Badge>
            </div>
            <Slider
              value={[localSettings.confidenceThreshold]}
              onValueChange={(val) => updateLocal("confidenceThreshold", val[0])}
              min={70}
              max={99}
              step={1}
              className="w-full"
            />
            <div className="flex justify-between text-xs text-slate-400">
              <span>70% (Tolérant)</span>
              <span>99% (Strict)</span>
            </div>
            <p className="text-xs text-slate-500">
              Les instruments détectés avec un score inférieur seront signalés comme incertains
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Connectivity */}
      <Card className="border-0 shadow-md">
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <Server className="w-5 h-5 text-indigo-600" />
            Connectivité & Synchronisation
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="flex items-center justify-between">
            <div className="space-y-1">
              <Label className="flex items-center gap-2">
                {localSettings.offlineMode ? (
                  <WifiOff className="w-4 h-4 text-amber-500" />
                ) : (
                  <Wifi className="w-4 h-4 text-emerald-500" />
                )}
                Mode hors ligne
              </Label>
              <p className="text-xs text-slate-500">
                Fonctionnement 100% local sans connexion internet
              </p>
            </div>
            <Switch
              checked={localSettings.offlineMode}
              onCheckedChange={(val) => updateLocal("offlineMode", val)}
            />
          </div>

          <Separator />

          <div className="flex items-center justify-between">
            <div className="space-y-1">
              <Label>Synchronisation automatique</Label>
              <p className="text-xs text-slate-500">
                Synchroniser les données quand une connexion est disponible
              </p>
            </div>
            <Switch
              checked={localSettings.autoSync}
              onCheckedChange={(val) => updateLocal("autoSync", val)}
              disabled={localSettings.offlineMode}
            />
          </div>

          {/* Sync Status */}
          <div className="p-4 rounded-xl bg-slate-50 space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-sm text-slate-600">Statut</span>
              <Badge className={syncStatus.isOnline ? "bg-emerald-500 text-white border-0" : "bg-red-500 text-white border-0"}>
                {syncStatus.isOnline ? "En ligne" : "Hors ligne"}
              </Badge>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-slate-600">Dernière synchronisation</span>
              <span className="text-sm text-slate-800">
                {syncStatus.lastSync
                  ? new Date(syncStatus.lastSync).toLocaleDateString("fr-FR", {
                      day: "numeric",
                      month: "short",
                      hour: "2-digit",
                      minute: "2-digit",
                    })
                  : "Jamais"}
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-slate-600">Uploads en attente</span>
              <span className="text-sm font-medium text-amber-600">
                {syncStatus.pendingUploads}
              </span>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Data Management */}
      <Card className="border-0 shadow-md">
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <Database className="w-5 h-5 text-indigo-600" />
            Gestion des Données
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <Button
              variant="outline"
              className="h-auto py-4 flex flex-col items-center gap-2"
              onClick={() => toast.info("Export JSON en cours...")}
            >
              <Download className="w-5 h-5 text-indigo-600" />
              <span className="font-medium">Exporter Base JSON</span>
              <span className="text-xs text-slate-500">Sauvegarder toutes les données</span>
            </Button>
            <Button
              variant="outline"
              className="h-auto py-4 flex flex-col items-center gap-2"
              onClick={() => toast.info("Sélectionnez un fichier JSON...")}
            >
              <Upload className="w-5 h-5 text-indigo-600" />
              <span className="font-medium">Importer Base JSON</span>
              <span className="text-xs text-slate-500">Restaurer depuis une sauvegarde</span>
            </Button>
          </div>
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <Info className="w-3 h-3" />
            Compatible avec le format surgical_instruments_tracker.json
          </p>
        </CardContent>
      </Card>

      {/* Security */}
      <Card className="border-0 shadow-md">
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <Shield className="w-5 h-5 text-indigo-600" />
            Sécurité & Conformité
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="p-4 rounded-xl bg-emerald-50 text-center space-y-2">
              <Lock className="w-6 h-6 text-emerald-600 mx-auto" />
              <p className="text-sm font-medium text-emerald-800">AES-256</p>
              <p className="text-xs text-emerald-600">Cryptage des données</p>
            </div>
            <div className="p-4 rounded-xl bg-blue-50 text-center space-y-2">
              <Shield className="w-6 h-6 text-blue-600 mx-auto" />
              <p className="text-sm font-medium text-blue-800">ISO 13485</p>
              <p className="text-xs text-blue-600">Dispositifs médicaux</p>
            </div>
            <div className="p-4 rounded-xl bg-indigo-50 text-center space-y-2">
              <Shield className="w-6 h-6 text-indigo-600 mx-auto" />
              <p className="text-sm font-medium text-indigo-800">FDA Class II</p>
              <p className="text-xs text-indigo-600">Conformité réglementaire</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* App Info */}
      <Card className="border-0 shadow-md bg-gradient-to-br from-slate-50 to-slate-100">
        <CardContent className="p-6 text-center space-y-2">
          <p className="font-bold text-slate-800">SteriScan Reconstruct</p>
          <p className="text-sm text-slate-500">Version 1.0.0</p>
          <p className="text-xs text-slate-400">
            Solution IA de traçabilité et reconstitution des kits d&apos;instruments chirurgicaux
          </p>
          <div className="flex justify-center gap-2 pt-2">
            <Badge variant="outline" className="text-xs">CE Mark</Badge>
            <Badge variant="outline" className="text-xs">ISO 13485</Badge>
            <Badge variant="outline" className="text-xs">FDA Class II</Badge>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
