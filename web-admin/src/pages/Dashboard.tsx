import { useState, useEffect, useCallback } from 'react';
import { supabase } from '../supabase';
import { useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell
} from 'recharts';
import {
  LayoutDashboard, Package, Receipt, Settings, LogOut,
  TrendingUp, AlertTriangle, ShoppingBag, RefreshCw, Bell,
  ArrowUpRight, ArrowDownRight, Lock, ChevronRight, Zap, Users, Wallet
} from 'lucide-react';

const COLORS = ['#FACC15', '#1C1C1E', '#6B7280', '#D97706'];

export default function Dashboard() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [activeTab, setActiveTab] = useState('overview');
  const [profile, setProfile] = useState<any>(null);
  const [products, setProducts] = useState<any[]>([]);
  const [sales, setSales] = useState<any[]>([]);
  const [newPassword, setNewPassword] = useState('');
  const [updatingPassword, setUpdatingPassword] = useState(false);
  const [passwordMsg, setPasswordMsg] = useState('');
  const [passwordError, setPasswordError] = useState(false);

  const fetchData = useCallback(async (showRefresh = false) => {
    if (showRefresh) setRefreshing(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { navigate('/login'); return; }

      const { data: profileData } = await supabase
        .from('profiles').select('*, boutiques(*)').eq('id', user.id).single();
      if (!profileData) throw new Error('Profile introuvable');
      setProfile(profileData);

      const [{ data: prods }, { data: sls }] = await Promise.all([
        supabase.from('products').select('*').eq('boutique_id', profileData.boutique_id).order('created_at', { ascending: false }),
        supabase.from('sales').select('*').eq('boutique_id', profileData.boutique_id).order('date', { ascending: false })
      ]);

      if (prods) setProducts(prods);
      if (sls) setSales(sls);
    } catch (e) { console.error(e); }
    finally { setLoading(false); setRefreshing(false); }
  }, [navigate]);

  useEffect(() => { fetchData(); }, [fetchData]);

  const handleLogout = async () => { await supabase.auth.signOut(); navigate('/'); };

  const handlePasswordChange = async (e: React.FormEvent) => {
    e.preventDefault();
    setUpdatingPassword(true);
    setPasswordMsg('');
    setPasswordError(false);
    const { error } = await supabase.auth.updateUser({ password: newPassword });
    if (error) { setPasswordError(true); setPasswordMsg(error.message); }
    else { setPasswordMsg('Mot de passe mis à jour avec succès ✓'); setNewPassword(''); }
    setUpdatingPassword(false);
  };

  const currency = profile?.boutiques?.currency || 'USD';
  const totalRevenue = sales.reduce((s, x) => s + Number(x.total), 0);
  const lowStock = products.filter(p => Number(p.stock_quantity) <= Number(p.minimum_stock));
  const todaySales = sales.filter(s => new Date(s.date).toDateString() === new Date().toDateString());
  const todayRevenue = todaySales.reduce((s, x) => s + Number(x.total), 0);

  // Build last 7 days chart data
  const last7 = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(); d.setDate(d.getDate() - (6 - i));
    const dayLabel = d.toLocaleDateString('fr-FR', { weekday: 'short' });
    const total = sales
      .filter(s => new Date(s.date).toDateString() === d.toDateString())
      .reduce((sum, s) => sum + Number(s.total), 0);
    return { day: dayLabel, total };
  });

  // Payment method breakdown
  const paymentBreakdown = sales.reduce((acc: any, s) => {
    acc[s.payment_method] = (acc[s.payment_method] || 0) + 1;
    return acc;
  }, {});
  const pieData = Object.entries(paymentBreakdown).map(([name, value]) => ({ name, value }));

  // Top products by stock value
  const topProducts = [...products]
    .sort((a, b) => b.selling_price * b.stock_quantity - a.selling_price * a.stock_quantity)
    .slice(0, 5);

  if (loading) return (
    <div className="min-h-screen flex items-center justify-center bg-[#0F0F10]">
      <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 1, ease: 'linear' }}
        className="w-10 h-10 border-4 border-yellow-400 border-t-transparent rounded-full" />
    </div>
  );

  return (
    <div className="min-h-screen bg-[#F2F2F7] flex font-sans text-gray-900">
      {/* PRO SIDEBAR */}
      <aside className="w-72 bg-[#1C1C1E] flex flex-col fixed h-full z-10 overflow-hidden">
        {/* Glow accent */}
        <div className="absolute top-0 left-0 w-full h-40 bg-yellow-400/5 blur-3xl pointer-events-none" />

        {/* Logo */}
        <div className="p-8 flex items-center gap-4 relative">
          <div className="w-10 h-10 bg-gradient-to-tr from-yellow-500 to-yellow-300 rounded-2xl flex items-center justify-center shadow-lg shadow-yellow-500/20">
            <span className="font-black text-white text-lg">Y</span>
          </div>
          <div>
            <p className="font-bold text-white tracking-tight text-base">Yellow Pos</p>
            <p className="text-xs text-gray-500 truncate max-w-[140px]">{profile?.boutiques?.name}</p>
          </div>
        </div>

        {/* Nav */}
        <nav className="flex-1 px-4 space-y-1 mt-2">
          <p className="text-xs font-semibold text-gray-600 uppercase tracking-widest px-4 mb-3">Navigation</p>
          <SideNavItem icon={<LayoutDashboard size={18}/>} label="Vue d'ensemble" active={activeTab === 'overview'} onClick={() => setActiveTab('overview')} badge={lowStock.length > 0 ? lowStock.length.toString() : undefined} />
          <SideNavItem icon={<Package size={18}/>} label="Inventaire" active={activeTab === 'products'} onClick={() => setActiveTab('products')} />
          <SideNavItem icon={<Receipt size={18}/>} label="Ventes" active={activeTab === 'sales'} onClick={() => setActiveTab('sales')} badge={todaySales.length > 0 ? todaySales.length.toString() : undefined} />
          <SideNavItem icon={<Wallet size={18}/>} label="Dépenses" active={activeTab === 'expenses'} onClick={() => setActiveTab('expenses')} />

          
          <div className="pt-6 pb-2">
            <p className="text-xs font-semibold text-gray-600 uppercase tracking-widest px-4 mb-3">Configuration</p>
          </div>
          <SideNavItem icon={<Settings size={18}/>} label="Paramètres" active={activeTab === 'settings'} onClick={() => setActiveTab('settings')} />
        </nav>

        {/* User card at bottom */}
        <div className="p-4 m-4 bg-white/5 rounded-2xl border border-white/10">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-yellow-400 to-orange-400 flex items-center justify-center font-bold text-white text-sm shrink-0">
              {profile?.boutiques?.name?.charAt(0) || 'A'}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-semibold text-white truncate">{profile?.boutiques?.name}</p>
              <p className="text-xs text-gray-500">Administrateur</p>
            </div>
          </div>
          <button onClick={handleLogout} className="mt-3 flex items-center gap-2 text-xs text-gray-500 hover:text-red-400 transition-colors w-full">
            <LogOut size={14} />
            <span>Se déconnecter</span>
          </button>
        </div>
      </aside>

      {/* MAIN */}
      <main className="flex-1 ml-72 min-h-screen">
        {/* Top Header Bar */}
        <header className="sticky top-0 z-20 bg-[#F2F2F7]/80 backdrop-blur-xl border-b border-gray-200/50 flex items-center justify-between px-10 h-16">
          <div>
            <h2 className="font-semibold text-gray-900 capitalize">
              {activeTab === 'overview' ? "Vue d'ensemble" : activeTab === 'products' ? 'Inventaire' : activeTab === 'sales' ? 'Ventes' : activeTab === 'expenses' ? 'Dépenses' : 'Paramètres'}
            </h2>
            <p className="text-xs text-gray-500">{new Date().toLocaleDateString('fr-FR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</p>
          </div>
          <div className="flex items-center gap-3">
            <button onClick={() => fetchData(true)} className={`p-2.5 bg-white rounded-xl border border-gray-200 hover:bg-gray-50 transition-colors shadow-sm ${refreshing ? 'animate-spin text-yellow-500' : 'text-gray-600'}`}>
              <RefreshCw size={16} />
            </button>
            <button className="p-2.5 bg-white rounded-xl border border-gray-200 hover:bg-gray-50 transition-colors shadow-sm text-gray-600 relative">
              <Bell size={16} />
              {lowStock.length > 0 && <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full" />}
            </button>
          </div>
        </header>

        <div className="p-10">
          <AnimatePresence mode="wait">

            {/* ── OVERVIEW ── */}
            {activeTab === 'overview' && (
              <motion.div key="overview" initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} transition={{ duration: 0.3 }}>

                {/* KPI Cards */}
                <div className="grid grid-cols-2 lg:grid-cols-4 gap-5 mb-8">
                  <KPICard title="Chiffre d'Affaires" value={`${totalRevenue.toLocaleString()} ${currency}`} sub="Total cumulé" icon={<TrendingUp size={20}/>} color="yellow" />
                  <KPICard title="Ventes Aujourd'hui" value={todaySales.length.toString()} sub={`${todayRevenue.toLocaleString()} ${currency} générés`} icon={<Zap size={20}/>} color="blue" />
                  <KPICard title="Produits Actifs" value={products.length.toString()} sub={`${lowStock.length} en stock faible`} icon={<ShoppingBag size={20}/>} color="green" />
                  <KPICard title="Stock Faible" value={lowStock.length.toString()} sub="Réapprovisionnement requis" icon={<AlertTriangle size={20}/>} color="red" urgent={lowStock.length > 0} />
                </div>

                {/* Charts Row */}
                <div className="grid grid-cols-3 gap-6 mb-8">
                  {/* Area Chart - Revenue 7 days */}
                  <div className="col-span-2 bg-white rounded-3xl p-7 border border-gray-100 shadow-sm">
                    <div className="flex justify-between items-start mb-6">
                      <div>
                        <h3 className="font-bold text-lg tracking-tight">Revenus — 7 derniers jours</h3>
                        <p className="text-sm text-gray-400 mt-0.5">Chiffre d'affaires journalier</p>
                      </div>
                      <span className="text-xs font-semibold bg-yellow-50 text-yellow-700 px-3 py-1.5 rounded-xl">7 jours</span>
                    </div>
                    {sales.length === 0 ? (
                      <EmptyChart />
                    ) : (
                      <ResponsiveContainer width="100%" height={200}>
                        <AreaChart data={last7}>
                          <defs>
                            <linearGradient id="revGrad" x1="0" y1="0" x2="0" y2="1">
                              <stop offset="5%" stopColor="#FACC15" stopOpacity={0.2}/>
                              <stop offset="95%" stopColor="#FACC15" stopOpacity={0}/>
                            </linearGradient>
                          </defs>
                          <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" />
                          <XAxis dataKey="day" tick={{ fontSize: 12, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
                          <YAxis tick={{ fontSize: 12, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
                          <Tooltip contentStyle={{ borderRadius: 12, border: 'none', boxShadow: '0 4px 24px rgba(0,0,0,0.08)', fontSize: 13 }} />
                          <Area type="monotone" dataKey="total" stroke="#FACC15" strokeWidth={3} fill="url(#revGrad)" dot={{ fill: '#FACC15', strokeWidth: 0, r: 4 }} />
                        </AreaChart>
                      </ResponsiveContainer>
                    )}
                  </div>

                  {/* Payment Breakdown Donut */}
                  <div className="bg-white rounded-3xl p-7 border border-gray-100 shadow-sm">
                    <h3 className="font-bold text-lg tracking-tight mb-1">Paiements</h3>
                    <p className="text-sm text-gray-400 mb-6">Répartition par méthode</p>
                    {pieData.length === 0 ? (
                      <EmptyChart />
                    ) : (
                      <>
                        <ResponsiveContainer width="100%" height={140}>
                          <PieChart>
                            <Pie data={pieData} cx="50%" cy="50%" innerRadius={42} outerRadius={65} paddingAngle={3} dataKey="value">
                              {pieData.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                            </Pie>
                            <Tooltip contentStyle={{ borderRadius: 12, fontSize: 12, border: 'none', boxShadow: '0 4px 24px rgba(0,0,0,0.08)' }} />
                          </PieChart>
                        </ResponsiveContainer>
                        <div className="space-y-2 mt-4">
                          {pieData.map((item, i) => (
                            <div key={i} className="flex justify-between items-center text-sm">
                              <div className="flex items-center gap-2">
                                <div className="w-2.5 h-2.5 rounded-full" style={{ background: COLORS[i % COLORS.length] }} />
                                <span className="text-gray-600 text-xs">{item.name}</span>
                              </div>
                              <span className="font-bold text-xs">{item.value as number}</span>
                            </div>
                          ))}
                        </div>
                      </>
                    )}
                  </div>
                </div>

                {/* Bottom Row: Top Products + Recent Sales */}
                <div className="grid grid-cols-2 gap-6">
                  {/* Top Products */}
                  <div className="bg-white rounded-3xl p-7 border border-gray-100 shadow-sm">
                    <div className="flex justify-between items-center mb-6">
                      <h3 className="font-bold text-lg tracking-tight">Top Produits</h3>
                      <button onClick={() => setActiveTab('products')} className="text-xs font-semibold text-yellow-600 hover:text-yellow-700 flex items-center gap-1">Voir tout <ChevronRight size={14}/></button>
                    </div>
                    {topProducts.length === 0 ? (
                      <EmptyState icon={<Package size={32}/>} text="Aucun produit synchronisé" sub="Importez des produits depuis l'app bureau" />
                    ) : (
                      <div className="space-y-4">
                        {topProducts.map((p, i) => (
                          <div key={p.id} className="flex items-center gap-4">
                            <div className="w-8 h-8 bg-gray-50 rounded-xl flex items-center justify-center font-bold text-gray-400 text-xs shrink-0">#{i+1}</div>
                            <div className="flex-1 min-w-0">
                              <p className="font-semibold text-sm truncate">{p.name}</p>
                              <p className="text-xs text-gray-400">{p.stock_quantity} {p.unit} en stock</p>
                            </div>
                            <div className="text-right shrink-0">
                              <p className="font-bold text-sm">{Number(p.selling_price).toLocaleString()}</p>
                              <p className="text-xs text-gray-400">{currency}</p>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* Recent Sales */}
                  <div className="bg-white rounded-3xl p-7 border border-gray-100 shadow-sm">
                    <div className="flex justify-between items-center mb-6">
                      <h3 className="font-bold text-lg tracking-tight">Dernières Ventes</h3>
                      <button onClick={() => setActiveTab('sales')} className="text-xs font-semibold text-yellow-600 hover:text-yellow-700 flex items-center gap-1">Voir tout <ChevronRight size={14}/></button>
                    </div>
                    {sales.length === 0 ? (
                      <EmptyState icon={<Receipt size={32}/>} text="Aucune vente enregistrée" sub="Les ventes apparaîtront dès la synchronisation" />
                    ) : (
                      <div className="space-y-3">
                        {sales.slice(0, 5).map((s) => (
                          <div key={s.id} className="flex items-center gap-4 p-3 rounded-2xl hover:bg-gray-50/80 transition-colors">
                            <div className="w-9 h-9 rounded-xl bg-yellow-50 flex items-center justify-center shrink-0">
                              <Receipt size={16} className="text-yellow-600" />
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="font-semibold text-sm">{s.sale_number}</p>
                              <p className="text-xs text-gray-400">{new Date(s.date).toLocaleString('fr-FR', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' })}</p>
                            </div>
                            <div className="text-right shrink-0">
                              <p className="font-bold text-sm text-green-600">+{Number(s.total).toLocaleString()}</p>
                              <p className="text-xs text-gray-400">{currency}</p>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>

                {/* Low Stock Alert */}
                {lowStock.length > 0 && (
                  <div className="mt-6 bg-red-50 border border-red-100 rounded-3xl p-6">
                    <div className="flex items-center gap-3 mb-4">
                      <AlertTriangle size={20} className="text-red-500" />
                      <h3 className="font-bold text-red-700">{lowStock.length} produit(s) en stock critique</h3>
                    </div>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                      {lowStock.map(p => (
                        <div key={p.id} className="bg-white rounded-2xl p-4 border border-red-100">
                          <p className="font-semibold text-sm truncate">{p.name}</p>
                          <p className="text-xs text-red-500 font-bold mt-1">{p.stock_quantity} {p.unit} restant(s)</p>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </motion.div>
            )}

            {/* ── PRODUCTS ── */}
            {activeTab === 'products' && (
              <motion.div key="products" initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} transition={{ duration: 0.3 }}>
                <div className="flex items-center justify-between mb-8">
                  <div>
                    <h1 className="text-2xl font-bold tracking-tight">Inventaire</h1>
                    <p className="text-gray-500 text-sm mt-1">{products.length} produits · {lowStock.length} en stock faible</p>
                  </div>
                </div>

                {products.length === 0 ? (
                  <div className="bg-white rounded-3xl border border-gray-100 shadow-sm p-16">
                    <EmptyState icon={<Package size={40}/>} text="Aucun produit synchronisé" sub="Ajoutez des produits via l'application de bureau Yellow Pos. Ils apparaîtront ici automatiquement lors de la prochaine synchronisation." />
                  </div>
                ) : (
                  <div className="bg-white rounded-3xl border border-gray-100 shadow-sm overflow-hidden">
                    <table className="w-full text-left border-collapse">
                      <thead>
                        <tr className="bg-gray-50/60 text-gray-500 text-xs font-semibold uppercase tracking-wider border-b border-gray-100">
                          <th className="py-4 px-6">Produit</th>
                          <th className="py-4 px-6">SKU</th>
                          <th className="py-4 px-6">Prix Achat</th>
                          <th className="py-4 px-6">Prix Vente</th>
                          <th className="py-4 px-6">Stock</th>
                          <th className="py-4 px-6">Statut</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-50">
                        {products.map((p) => {
                          const isLow = Number(p.stock_quantity) <= Number(p.minimum_stock);
                          const pct = p.minimum_stock > 0 ? Math.min(100, (p.stock_quantity / (p.minimum_stock * 3)) * 100) : 100;
                          return (
                            <tr key={p.id} className="hover:bg-gray-50/50 transition-colors group">
                              <td className="py-4 px-6">
                                <div className="flex items-center gap-3">
                                  <div className="w-9 h-9 bg-yellow-50 rounded-xl flex items-center justify-center shrink-0 text-yellow-600 font-bold text-xs">
                                    {p.name.charAt(0).toUpperCase()}
                                  </div>
                                  <span className="font-semibold text-sm">{p.name}</span>
                                </div>
                              </td>
                              <td className="py-4 px-6 font-mono text-xs text-gray-400">{p.sku || p.barcode || '—'}</td>
                              <td className="py-4 px-6 text-sm text-gray-500">{Number(p.purchase_price).toLocaleString()} {currency}</td>
                              <td className="py-4 px-6 font-bold text-sm">{Number(p.selling_price).toLocaleString()} {currency}</td>
                              <td className="py-4 px-6">
                                <div className="flex items-center gap-3">
                                  <div className="w-20 h-1.5 bg-gray-100 rounded-full overflow-hidden">
                                    <div className={`h-full rounded-full transition-all ${isLow ? 'bg-red-400' : 'bg-green-400'}`} style={{ width: `${pct}%` }} />
                                  </div>
                                  <span className="text-xs font-medium text-gray-600">{p.stock_quantity} {p.unit}</span>
                                </div>
                              </td>
                              <td className="py-4 px-6">
                                <StatusBadge ok={!isLow} labelOk="En Stock" labelBad="Stock Faible" />
                              </td>
                            </tr>
                          );
                        })}
                      </tbody>
                    </table>
                  </div>
                )}
              </motion.div>
            )}

            {/* ── SALES ── */}
            {activeTab === 'sales' && (
              <motion.div key="sales" initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} transition={{ duration: 0.3 }}>
                <div className="flex items-center justify-between mb-8">
                  <div>
                    <h1 className="text-2xl font-bold tracking-tight">Historique des Ventes</h1>
                    <p className="text-gray-500 text-sm mt-1">{sales.length} transactions · {totalRevenue.toLocaleString()} {currency} total</p>
                  </div>
                  <div className="flex gap-3">
                    <div className="bg-white rounded-2xl border border-gray-200 px-5 py-3 shadow-sm">
                      <p className="text-xs text-gray-400">Aujourd'hui</p>
                      <p className="font-bold text-sm">{todaySales.length} ventes</p>
                    </div>
                    <div className="bg-yellow-400 rounded-2xl px-5 py-3 shadow-sm shadow-yellow-200">
                      <p className="text-xs text-yellow-800">Revenus du jour</p>
                      <p className="font-bold text-sm text-yellow-900">{todayRevenue.toLocaleString()} {currency}</p>
                    </div>
                  </div>
                </div>

                {sales.length === 0 ? (
                  <div className="bg-white rounded-3xl border border-gray-100 shadow-sm p-16">
                    <EmptyState icon={<Receipt size={40}/>} text="Aucune vente enregistrée" sub="Les transactions de votre caisse apparaîtront ici automatiquement après synchronisation." />
                  </div>
                ) : (
                  <div className="bg-white rounded-3xl border border-gray-100 shadow-sm overflow-hidden">
                    <table className="w-full text-left border-collapse">
                      <thead>
                        <tr className="bg-gray-50/60 text-gray-500 text-xs font-semibold uppercase tracking-wider border-b border-gray-100">
                          <th className="py-4 px-6">N° Facture</th>
                          <th className="py-4 px-6">Date & Heure</th>
                          <th className="py-4 px-6">Méthode</th>
                          <th className="py-4 px-6 text-right">Montant</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-50">
                        {sales.map((s) => (
                          <tr key={s.id} className="hover:bg-gray-50/50 transition-colors">
                            <td className="py-4 px-6 font-mono text-sm font-medium">{s.sale_number}</td>
                            <td className="py-4 px-6 text-sm text-gray-500">{new Date(s.date).toLocaleString('fr-FR')}</td>
                            <td className="py-4 px-6"><PayBadge method={s.payment_method} /></td>
                            <td className="py-4 px-6 text-right font-bold text-base text-green-600">+{Number(s.total).toLocaleString()} {currency}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </motion.div>
            )}

            {/* ── SETTINGS ── */}
            {/* ── EXPENSES ── */}
            {activeTab === 'expenses' && (
              <motion.div key="expenses" initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} transition={{ duration: 0.3 }}>
                <h1 className="text-2xl font-bold tracking-tight mb-8">Dépenses</h1>
                <div className="bg-white rounded-3xl p-12 text-center border border-gray-100 shadow-sm">
                  <Wallet size={48} className="mx-auto text-gray-300 mb-4" />
                  <h3 className="text-xl font-bold text-gray-800 mb-2">Gestion des dépenses</h3>
                  <p className="text-gray-500 mb-6">Cette fonctionnalité sera bientôt disponible dans une prochaine mise à jour.</p>
                </div>
              </motion.div>
            )}


            {activeTab === 'settings' && (
              <motion.div key="settings" initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} transition={{ duration: 0.3 }}>
                <h1 className="text-2xl font-bold tracking-tight mb-8">Paramètres</h1>
                <div className="grid grid-cols-2 gap-6">

                  {/* Store Info */}
                  <div className="bg-white rounded-3xl p-8 border border-gray-100 shadow-sm">
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 bg-yellow-50 rounded-2xl flex items-center justify-center"><Users, Wallet size={18} className="text-yellow-600"/></div>
                      <h2 className="font-bold text-lg">Informations Boutique</h2>
                    </div>
                    <div className="space-y-5">
                      <div>
                        <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Nom de la Boutique</label>
                        <input disabled value={profile?.boutiques?.name || ''} className="w-full bg-gray-50 border border-gray-200 px-4 py-3 rounded-2xl text-gray-800 font-semibold text-sm"/>
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">ID Unique</label>
                        <code className="block w-full bg-gray-900 text-green-400 px-4 py-3 rounded-2xl text-xs select-all font-mono leading-relaxed break-all">{profile?.boutique_id}</code>
                        <p className="text-xs text-gray-400 mt-2 ml-1">Copiez cet ID dans l'application de bureau pour activer la synchronisation.</p>
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Devise</label>
                        <input disabled value={currency} className="w-full bg-gray-50 border border-gray-200 px-4 py-3 rounded-2xl text-gray-800 font-bold text-sm"/>
                      </div>
                    </div>
                  </div>

                  {/* Security */}
                  <div className="bg-white rounded-3xl p-8 border border-gray-100 shadow-sm">
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 bg-gray-100 rounded-2xl flex items-center justify-center"><Lock size={18} className="text-gray-600"/></div>
                      <h2 className="font-bold text-lg">Sécurité</h2>
                    </div>

                    {passwordMsg && (
                      <div className={`p-4 rounded-2xl mb-5 text-sm font-medium flex items-center gap-2 ${passwordError ? 'bg-red-50 text-red-600' : 'bg-green-50 text-green-600'}`}>
                        {passwordMsg}
                      </div>
                    )}

                    <form onSubmit={handlePasswordChange} className="space-y-4">
                      <div>
                        <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Nouveau mot de passe</label>
                        <div className="relative">
                          <div className="absolute inset-y-0 left-0 pl-4 flex items-center text-gray-400 pointer-events-none"><Lock size={16}/></div>
                          <input
                            type="password" value={newPassword} onChange={e => setNewPassword(e.target.value)}
                            className="w-full pl-10 pr-4 py-3.5 bg-gray-50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all text-sm"
                            placeholder="Min. 6 caractères" required minLength={6}
                          />
                        </div>
                      </div>
                      <button type="submit" disabled={updatingPassword}
                        className="w-full bg-gray-900 text-white rounded-2xl py-3.5 font-semibold hover:bg-gray-800 active:scale-[0.98] transition-all disabled:opacity-50 flex items-center justify-center gap-2 text-sm">
                        {updatingPassword ? <><RefreshCw size={14} className="animate-spin"/>Mise à jour...</> : 'Changer le mot de passe'}
                      </button>
                    </form>

                    <div className="mt-6 pt-6 border-t border-gray-100">
                      <p className="text-xs text-gray-400 mb-3 font-semibold uppercase tracking-wider">Zone de danger</p>
                      <button onClick={handleLogout} className="w-full flex items-center justify-center gap-2 py-3 rounded-2xl border-2 border-red-100 text-red-500 hover:bg-red-50 transition-colors font-semibold text-sm">
                        <LogOut size={16}/> Se déconnecter
                      </button>
                    </div>
                  </div>
                </div>
              </motion.div>
            )}

          </AnimatePresence>
        </div>
      </main>
    </div>
  );
}

// ── Sub-components ──

function SideNavItem({ icon, label, active, onClick, badge }: { icon: any, label: string, active: boolean, onClick: () => void, badge?: string }) {
  return (
    <button onClick={onClick} className={`flex items-center gap-3 w-full px-4 py-3 rounded-2xl transition-all text-sm font-medium relative
      ${active ? 'bg-yellow-400 text-gray-900 shadow-lg shadow-yellow-400/20' : 'text-gray-400 hover:bg-white/5 hover:text-white'}`}>
      <span className={active ? 'text-gray-900' : ''}>{icon}</span>
      <span className="flex-1 text-left">{label}</span>
      {badge && (
        <span className={`text-xs font-bold px-2 py-0.5 rounded-full ${active ? 'bg-gray-900/10 text-gray-900' : 'bg-red-500 text-white'}`}>{badge}</span>
      )}
    </button>
  );
}

function KPICard({ title, value, sub, icon, color, urgent }: { title: string, value: string, sub: string, icon: any, color: string, urgent?: boolean }) {
  const bg: any = { yellow: 'bg-yellow-50 text-yellow-600', blue: 'bg-blue-50 text-blue-600', green: 'bg-green-50 text-green-600', red: 'bg-red-50 text-red-500' };
  return (
    <motion.div whileHover={{ y: -2 }} className={`bg-white rounded-3xl p-6 border shadow-sm flex flex-col gap-3 ${urgent ? 'border-red-200' : 'border-gray-100'}`}>
      <div className="flex items-center justify-between">
        <div className={`w-11 h-11 rounded-2xl ${bg[color]} flex items-center justify-center`}>{icon}</div>
        <ArrowUpRight size={16} className="text-gray-300" />
      </div>
      <div>
        <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">{title}</p>
        <p className="text-2xl font-black tracking-tight text-gray-900 mt-1">{value}</p>
        <p className="text-xs text-gray-400 mt-1">{sub}</p>
      </div>
    </motion.div>
  );
}

function StatusBadge({ ok, labelOk, labelBad }: { ok: boolean, labelOk: string, labelBad: string }) {
  return (
    <span className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold ${ok ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-600'}`}>
      <span className={`w-1.5 h-1.5 rounded-full ${ok ? 'bg-green-500' : 'bg-red-500'}`} />
      {ok ? labelOk : labelBad}
    </span>
  );
}

function PayBadge({ method }: { method: string }) {
  const isCard = method?.toLowerCase().includes('card') || method?.toLowerCase().includes('carte');
  return (
    <span className={`px-3 py-1.5 rounded-full text-xs font-bold ${isCard ? 'bg-blue-50 text-blue-700' : 'bg-gray-100 text-gray-700'}`}>
      {method}
    </span>
  );
}

function EmptyState({ icon, text, sub }: { icon: any, text: string, sub: string }) {
  return (
    <div className="flex flex-col items-center justify-center py-12 text-center">
      <div className="w-16 h-16 bg-gray-50 rounded-3xl flex items-center justify-center text-gray-300 mb-4">{icon}</div>
      <p className="font-semibold text-gray-600 mb-1">{text}</p>
      <p className="text-sm text-gray-400 max-w-xs">{sub}</p>
    </div>
  );
}

function EmptyChart() {
  return (
    <div className="flex items-center justify-center h-[200px] text-gray-300">
      <div className="text-center">
        <ArrowDownRight size={32} className="mx-auto mb-2 opacity-30" />
        <p className="text-sm">Données disponibles après synchronisation</p>
      </div>
    </div>
  );
}
