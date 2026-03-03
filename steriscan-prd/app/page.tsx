"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Camera, Upload, CheckCircle, AlertTriangle } from "lucide-react"

export default function SteriScanApp() {
  const [isScanning, setIsScanning] = useState(false)
  const [scanComplete, setScanComplete] = useState(false)
  const [selectedImage, setSelectedImage] = useState("")

  const instruments = [
    { id: "INST-001", name: "Ciseaux de Mayo", status: "present" },
    { id: "INST-002", name: "Pince Hémostatique", status: "missing" },
    { id: "INST-003", name: "Scalpel #10", status: "present" },
    { id: "INST-004", name: "Pince Anatomique", status: "extra" },
    { id: "INST-005", name: "Porte-aiguille", status: "present" },
  ]

  const simulateScan = () => {
    setIsScanning(true)
    setTimeout(() => {
      setIsScanning(false)
      setScanComplete(true)
    }, 2000)
  }

  const handleImageUpload = (event: any) => {
    const file = event.target.files?.[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e: any) => {
        setSelectedImage(e.target.result)
      }
      reader.readAsDataURL(file)
    }
  }

  const getStatusColor = (status: string) => {
    if (status === "present") return "bg-green-500"
    if (status === "missing") return "bg-red-500"
    return "bg-orange-500"
  }

  const getStatusText = (status: string) => {
    if (status === "present") return "Présent"
    if (status === "missing") return "Manquant"
    return "En surplus"
  }

  const conformityScore = Math.round(
    (instruments.filter((i) => i.status === "present").length / instruments.length) * 100,
  )

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
      <div className="max-w-4xl mx-auto space-y-6">
        {/* Header */}
        <Card className="bg-white shadow-lg">
          <CardHeader className="text-center">
            <CardTitle className="text-3xl font-bold text-indigo-800 flex items-center justify-center gap-2">
              <Camera className="w-8 h-8" />
              SteriScan Reconstruct
            </CardTitle>
            <p className="text-gray-600">Scanner IA pour kits d'instruments chirurgicaux</p>
          </CardHeader>
        </Card>

        {/* Scanner Interface */}
        <Card className="bg-white shadow-lg">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Upload className="w-5 h-5" />
              Scanner un Kit
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {/* Image Upload */}
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
              {selectedImage ? (
                <div className="space-y-4">
                  <img
                    src={selectedImage || "/placeholder.svg"}
                    alt="Kit scanné"
                    className="max-w-full h-48 object-contain mx-auto rounded-lg"
                  />
                  <p className="text-sm text-gray-600">Image chargée avec succès</p>
                </div>
              ) : (
                <div className="space-y-4">
                  <Camera className="w-16 h-16 text-gray-400 mx-auto" />
                  <p className="text-gray-600">Prenez une photo ou importez une image du kit</p>
                </div>
              )}

              <input type="file" accept="image/*" onChange={handleImageUpload} className="hidden" id="image-upload" />
              <label
                htmlFor="image-upload"
                className="inline-block mt-4 px-6 py-2 bg-indigo-600 text-white rounded-lg cursor-pointer hover:bg-indigo-700 transition-colors"
              >
                Choisir une image
              </label>
            </div>

            {/* Scan Button */}
            <div className="flex justify-center">
              <Button
                onClick={simulateScan}
                disabled={isScanning || !selectedImage}
                className="px-8 py-3 bg-green-600 hover:bg-green-700"
              >
                {isScanning ? "Analyse en cours..." : "Démarrer le Scan IA"}
              </Button>
            </div>

            {/* Loading Animation */}
            {isScanning && (
              <div className="text-center space-y-4">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto"></div>
                <p className="text-indigo-600 font-medium">Reconnaissance IA en cours...</p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Results */}
        {scanComplete && (
          <>
            {/* Conformity Score */}
            <Card className="bg-white shadow-lg">
              <CardContent className="pt-6">
                <div className="text-center space-y-4">
                  <div
                    className={`inline-flex items-center gap-2 px-6 py-3 rounded-full text-white font-bold text-xl ${
                      conformityScore >= 90 ? "bg-green-500" : conformityScore >= 70 ? "bg-orange-500" : "bg-red-500"
                    }`}
                  >
                    {conformityScore >= 90 ? (
                      <CheckCircle className="w-5 h-5" />
                    ) : (
                      <AlertTriangle className="w-5 h-5" />
                    )}
                    Score de Conformité: {conformityScore}%
                  </div>
                  <p className="text-gray-600">
                    {conformityScore >= 90
                      ? "Kit conforme ✅"
                      : conformityScore >= 70
                        ? "Kit partiellement conforme ⚠️"
                        : "Kit non conforme ❌"}
                  </p>
                </div>
              </CardContent>
            </Card>

            {/* Instruments List */}
            <Card className="bg-white shadow-lg">
              <CardHeader>
                <CardTitle>Résultats de la Reconnaissance</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {instruments.map((instrument) => (
                    <div
                      key={instrument.id}
                      className="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50 transition-colors"
                    >
                      <div className="flex items-center gap-3">
                        {instrument.status === "present" ? (
                          <CheckCircle className="w-4 h-4 text-green-500" />
                        ) : (
                          <AlertTriangle className="w-4 h-4 text-red-500" />
                        )}
                        <div>
                          <p className="font-medium">{instrument.name}</p>
                          <p className="text-sm text-gray-600">ID: {instrument.id}</p>
                        </div>
                      </div>

                      <Badge className={`${getStatusColor(instrument.status)} text-white`}>
                        {getStatusText(instrument.status)}
                      </Badge>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Actions */}
            <Card className="bg-white shadow-lg">
              <CardContent className="pt-6">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <Button className="w-full bg-blue-600 hover:bg-blue-700">Exporter Rapport PDF</Button>
                  <Button className="w-full bg-purple-600 hover:bg-purple-700">Sauvegarder Composition</Button>
                  <Button className="w-full bg-orange-600 hover:bg-orange-700">Reconstituer Kit</Button>
                </div>
              </CardContent>
            </Card>
          </>
        )}

        {/* Footer */}
        <div className="text-center text-sm text-gray-600 py-4">
          <p>SteriScan Reconstruct v1.0 - Conformité ISO 13485 | CE Mark | FDA Class II</p>
        </div>
      </div>
    </div>
  )
}
