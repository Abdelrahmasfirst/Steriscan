import type React from "react"
import type { Metadata } from "next"
import { Inter } from "next/font/google"
import "./globals.css"
import { AppSidebar } from "@/components/app-sidebar"
import { AppProvider } from "@/lib/app-context"
import { Toaster } from "@/components/ui/sonner"

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "SteriScan Reconstruct",
  description: "Solution IA de traçabilité et reconstitution des kits d'instruments chirurgicaux",
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr">
      <body className={inter.className}>
        <AppProvider>
          <div className="flex min-h-screen bg-slate-50">
            <AppSidebar />
            <main className="flex-1 md:ml-64 min-h-screen">
              {children}
            </main>
          </div>
          <Toaster position="top-right" richColors />
        </AppProvider>
      </body>
    </html>
  )
}
