import CssBaseline from "@mui/material/CssBaseline";
import { ThemeProvider } from "@mui/material/styles";
import type { Metadata } from "next";
import { PlayerProvider } from "@/contexts/PlayerContext";
import { theme } from "./theme";

export const metadata: Metadata = {
  title: "Elixir Radio - Record Store",
  description: "Browse and preview records from our collection",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <ThemeProvider theme={theme}>
          <CssBaseline />
          <PlayerProvider>{children}</PlayerProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
