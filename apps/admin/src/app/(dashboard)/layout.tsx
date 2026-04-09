export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen">
      {/* Sidebar */}
      <aside className="w-56 border-r border-white/10 bg-white/5 p-4">
        <div className="mb-8">
          <span className="text-lg font-bold" style={{ color: 'var(--color-accent)' }}>
            HowlAlert
          </span>
        </div>
        <nav className="flex flex-col gap-1 text-sm">
          <a href="/dashboard" className="rounded-lg px-3 py-2 text-white/70 hover:bg-white/10 hover:text-white">
            Overview
          </a>
          <a href="/dashboard/push-log" className="rounded-lg px-3 py-2 text-white/70 hover:bg-white/10 hover:text-white">
            Push Log
          </a>
          <a href="/dashboard/config" className="rounded-lg px-3 py-2 text-white/70 hover:bg-white/10 hover:text-white">
            Config
          </a>
        </nav>
      </aside>

      {/* Main content */}
      <main className="flex-1 p-8">{children}</main>
    </div>
  );
}
