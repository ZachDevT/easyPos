import { useState, useEffect } from 'react';
import { supabase } from '../supabase';
import { useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  LayoutDashboard, 
  Package, 
  Receipt, 
  Settings, 
  LogOut,
  TrendingUp,
  AlertCircle,
  PackageOpen,
  Lock
} from 'lucide-react';

export default function Dashboard() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('overview');
  
  // Data States
  const [profile, setProfile] = useState<any>(null);
  const [products, setProducts] = useState<any[]>([]);
  const [sales, setSales] = useState<any[]>([]);

  // Password States
  const [newPassword, setNewPassword] = useState('');
  const [updatingPassword, setUpdatingPassword] = useState(false);
  const [passwordMsg, setPasswordMsg] = useState('');
  const [passwordError, setPasswordError] = useState(false);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        navigate('/login');
        return;
      }

      const { data: profileData } = await supabase
        .from('profiles')
        .select('*, boutiques(*)')
        .eq('id', user.id)
        .single();
      
      if (!profileData) throw new Error("Profile not found");
      setProfile(profileData);

      const boutiqueId = profileData.boutique_id;

      const { data: productsData } = await supabase
        .from('products')
        .select('*')
        .eq('boutique_id', boutiqueId)
        .order('created_at', { ascending: false });
      
      if (productsData) setProducts(productsData);

      const { data: salesData } = await supabase
        .from('sales')
        .select('*')
        .eq('boutique_id', boutiqueId)
        .order('date', { ascending: false });

      if (salesData) setSales(salesData);

    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/');
  };

  const handlePasswordChange = async (e: React.FormEvent) => {
    e.preventDefault();
    setUpdatingPassword(true);
    setPasswordMsg('');
    setPasswordError(false);
    
    try {
      const { error } = await supabase.auth.updateUser({ password: newPassword });
      if (error) throw error;
      
      setPasswordMsg('Mot de passe mis à jour avec succès.');
      setNewPassword('');
    } catch (err: any) {
      setPasswordError(true);
      setPasswordMsg(err.message || 'Une erreur est survenue.');
    } finally {
      setUpdatingPassword(false);
    }
  };

  // Calculations
  const totalRevenue = sales.reduce((sum, sale) => sum + Number(sale.total), 0);
  const totalProducts = products.length;
  const lowStockProducts = products.filter(p => Number(p.stock_quantity) <= Number(p.minimum_stock));
  const currency = profile?.boutiques?.currency || 'USD';

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#FBFBFD]">
        <div className="w-10 h-10 border-4 border-yellow-400 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#FBFBFD] flex font-sans text-gray-900">
      <aside className="w-64 bg-white border-r border-gray-100 flex flex-col fixed h-full z-10">
        <div className="p-8 flex items-center gap-3">
          <div className="w-8 h-8 bg-gradient-to-tr from-yellow-400 to-yellow-300 rounded-lg flex items-center justify-center shadow-sm">
            <span className="text-white font-bold">Y</span>
          </div>
          <span className="font-bold tracking-tight text-lg truncate">
            {profile?.boutiques?.name || 'Yellow Pos'}
          </span>
        </div>

        <nav className="flex-1 px-4 space-y-2 mt-4">
          <NavItem icon={<LayoutDashboard size={20}/>} label="Vue d'ensemble" active={activeTab === 'overview'} onClick={() => setActiveTab('overview')} />
          <NavItem icon={<Package size={20}/>} label="Produits" active={activeTab === 'products'} onClick={() => setActiveTab('products')} />
          <NavItem icon={<Receipt size={20}/>} label="Ventes" active={activeTab === 'sales'} onClick={() => setActiveTab('sales')} />
          <NavItem icon={<Settings size={20}/>} label="Paramètres" active={activeTab === 'settings'} onClick={() => setActiveTab('settings')} />
        </nav>

        <div className="p-4 border-t border-gray-50">
          <button onClick={handleLogout} className="flex items-center gap-3 w-full px-4 py-3 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-xl transition-all font-medium">
            <LogOut size={20} />
            Déconnexion
          </button>
        </div>
      </aside>

      <main className="flex-1 ml-64 p-10">
        <AnimatePresence mode="wait">
          
          {/* OVERVIEW TAB */}
          {activeTab === 'overview' && (
            <motion.div key="overview" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
              <header className="mb-10">
                <h1 className="text-3xl font-bold tracking-tight mb-2">Bonjour, {profile?.boutiques?.name} 👋</h1>
                <p className="text-gray-500">Voici ce qui se passe dans votre boutique aujourd'hui.</p>
              </header>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
                <StatCard 
                  title="Chiffre d'Affaires" 
                  value={`${totalRevenue.toLocaleString()} ${currency}`} 
                  icon={<TrendingUp size={24} className="text-green-500"/>} 
                  bg="bg-green-50"
                />
                <StatCard 
                  title="Produits Actifs" 
                  value={totalProducts.toString()} 
                  icon={<PackageOpen size={24} className="text-blue-500"/>} 
                  bg="bg-blue-50"
                />
                <StatCard 
                  title="Stock Faible" 
                  value={lowStockProducts.length.toString()} 
                  icon={<AlertCircle size={24} className="text-red-500"/>} 
                  bg="bg-red-50"
                  alert={lowStockProducts.length > 0}
                />
              </div>

              {/* Recent Sales Preview */}
              <div className="bg-white rounded-[2rem] p-8 border border-gray-100 shadow-[0_8px_30px_rgb(0,0,0,0.04)]">
                <div className="flex justify-between items-center mb-6">
                  <h2 className="text-xl font-bold tracking-tight">Dernières Ventes</h2>
                  <button onClick={() => setActiveTab('sales')} className="text-yellow-600 font-medium hover:underline text-sm">Voir tout</button>
                </div>
                {sales.length === 0 ? (
                  <p className="text-gray-400 py-4 text-center">Aucune vente enregistrée pour le moment.</p>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                      <thead>
                        <tr className="text-gray-400 text-sm border-b border-gray-100">
                          <th className="pb-3 font-medium">Facture</th>
                          <th className="pb-3 font-medium">Date</th>
                          <th className="pb-3 font-medium">Méthode</th>
                          <th className="pb-3 font-medium text-right">Total</th>
                        </tr>
                      </thead>
                      <tbody>
                        {sales.slice(0, 5).map((sale) => (
                          <tr key={sale.id} className="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                            <td className="py-4 font-medium">{sale.sale_number}</td>
                            <td className="py-4 text-gray-500">{new Date(sale.date).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', hour: '2-digit', minute:'2-digit'})}</td>
                            <td className="py-4"><Badge text={sale.payment_method} /></td>
                            <td className="py-4 text-right font-bold">{Number(sale.total).toLocaleString()} {currency}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </motion.div>
          )}

          {/* PRODUCTS TAB */}
          {activeTab === 'products' && (
            <motion.div key="products" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
              <header className="mb-8 flex justify-between items-end">
                <div>
                  <h1 className="text-3xl font-bold tracking-tight mb-2">Inventaire</h1>
                  <p className="text-gray-500">Gérez vos {products.length} produits synchronisés en temps réel.</p>
                </div>
              </header>

              <div className="bg-white rounded-[2rem] border border-gray-100 shadow-[0_8px_30px_rgb(0,0,0,0.04)] overflow-hidden">
                {products.length === 0 ? (
                  <div className="p-12 text-center text-gray-400">Aucun produit synchronisé.</div>
                ) : (
                  <table className="w-full text-left border-collapse">
                    <thead className="bg-gray-50/50">
                      <tr className="text-gray-500 text-sm border-b border-gray-100">
                        <th className="py-4 px-6 font-medium">Nom du Produit</th>
                        <th className="py-4 px-6 font-medium">SKU / Code</th>
                        <th className="py-4 px-6 font-medium">Prix Vente</th>
                        <th className="py-4 px-6 font-medium">En Stock</th>
                        <th className="py-4 px-6 font-medium">Statut</th>
                      </tr>
                    </thead>
                    <tbody>
                      {products.map((p) => {
                        const isLow = Number(p.stock_quantity) <= Number(p.minimum_stock);
                        return (
                          <tr key={p.id} className="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                            <td className="py-4 px-6 font-semibold">{p.name}</td>
                            <td className="py-4 px-6 text-gray-500 font-mono text-sm">{p.sku || p.barcode || '-'}</td>
                            <td className="py-4 px-6 font-medium">{Number(p.selling_price).toLocaleString()} {currency}</td>
                            <td className="py-4 px-6">{p.stock_quantity} {p.unit}</td>
                            <td className="py-4 px-6">
                              {isLow ? <Badge text="Stock Faible" color="red" /> : <Badge text="En Stock" color="green" />}
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                )}
              </div>
            </motion.div>
          )}

          {/* SALES TAB */}
          {activeTab === 'sales' && (
            <motion.div key="sales" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
              <header className="mb-8">
                <h1 className="text-3xl font-bold tracking-tight mb-2">Historique des Ventes</h1>
                <p className="text-gray-500">Toutes les transactions effectuées depuis l'application de caisse.</p>
              </header>

              <div className="bg-white rounded-[2rem] border border-gray-100 shadow-[0_8px_30px_rgb(0,0,0,0.04)] overflow-hidden">
                {sales.length === 0 ? (
                  <div className="p-12 text-center text-gray-400">Aucune vente synchronisée.</div>
                ) : (
                  <table className="w-full text-left border-collapse">
                    <thead className="bg-gray-50/50">
                      <tr className="text-gray-500 text-sm border-b border-gray-100">
                        <th className="py-4 px-6 font-medium">N° Facture</th>
                        <th className="py-4 px-6 font-medium">Date & Heure</th>
                        <th className="py-4 px-6 font-medium">Méthode</th>
                        <th className="py-4 px-6 font-medium text-right">Montant Total</th>
                      </tr>
                    </thead>
                    <tbody>
                      {sales.map((sale) => (
                        <tr key={sale.id} className="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                          <td className="py-4 px-6 font-medium font-mono text-sm text-gray-600">{sale.sale_number}</td>
                          <td className="py-4 px-6 text-gray-500">{new Date(sale.date).toLocaleString('fr-FR')}</td>
                          <td className="py-4 px-6"><Badge text={sale.payment_method} /></td>
                          <td className="py-4 px-6 text-right font-bold text-lg">{Number(sale.total).toLocaleString()} {currency}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                )}
              </div>
            </motion.div>
          )}

          {/* SETTINGS TAB */}
          {activeTab === 'settings' && (
            <motion.div key="settings" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
              <header className="mb-8">
                <h1 className="text-3xl font-bold tracking-tight mb-2">Paramètres</h1>
                <p className="text-gray-500">Gérez vos informations techniques et votre sécurité.</p>
              </header>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                {/* Store Info */}
                <div className="bg-white p-8 rounded-[2rem] border border-gray-100 shadow-[0_8px_30px_rgb(0,0,0,0.04)]">
                  <h2 className="text-xl font-bold mb-6">Informations Boutique</h2>
                  <div className="space-y-6">
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">ID Unique de la Boutique</label>
                      <div className="flex gap-3">
                        <code className="flex-1 bg-gray-50 border border-gray-200 px-4 py-3 rounded-xl text-gray-600 text-sm select-all">
                          {profile?.boutique_id}
                        </code>
                      </div>
                      <p className="text-xs text-gray-400 mt-2">Cet identifiant relie vos caisses hors-ligne à ce tableau de bord cloud.</p>
                    </div>
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">Devise Principale</label>
                      <input disabled type="text" value={currency} className="w-full bg-gray-50 border border-gray-200 px-4 py-3 rounded-xl text-gray-600 text-sm font-bold"/>
                    </div>
                  </div>
                </div>

                {/* Security */}
                <div className="bg-white p-8 rounded-[2rem] border border-gray-100 shadow-[0_8px_30px_rgb(0,0,0,0.04)]">
                  <h2 className="text-xl font-bold mb-6">Sécurité</h2>
                  
                  {passwordMsg && (
                    <div className={`p-4 rounded-xl mb-6 text-sm font-medium ${passwordError ? 'bg-red-50 text-red-600' : 'bg-green-50 text-green-600'}`}>
                      {passwordMsg}
                    </div>
                  )}

                  <form onSubmit={handlePasswordChange} className="space-y-5">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Nouveau mot de passe</label>
                      <div className="relative">
                        <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400">
                          <Lock size={20} />
                        </div>
                        <input 
                          type="password" 
                          value={newPassword}
                          onChange={e => setNewPassword(e.target.value)}
                          className="w-full pl-12 pr-4 py-3 bg-gray-50/50 rounded-xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
                          placeholder="••••••••"
                          required
                          minLength={6}
                        />
                      </div>
                    </div>
                    <button type="submit" disabled={updatingPassword} className="w-full bg-gray-900 text-white rounded-xl py-3 font-medium hover:bg-gray-800 active:scale-[0.98] transition-all shadow-md disabled:opacity-50">
                      {updatingPassword ? 'Mise à jour...' : 'Changer le mot de passe'}
                    </button>
                  </form>
                </div>
              </div>
            </motion.div>
          )}

        </AnimatePresence>
      </main>
    </div>
  );
}

// Helper Components
function NavItem({ icon, label, active, onClick }: { icon: any, label: string, active: boolean, onClick: () => void }) {
  return (
    <button 
      onClick={onClick}
      className={`flex items-center gap-3 w-full px-4 py-3 rounded-xl transition-all font-medium text-sm
        ${active ? 'bg-yellow-400/10 text-yellow-700' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'}
      `}
    >
      <span className={active ? 'text-yellow-600' : 'text-gray-400'}>{icon}</span>
      {label}
    </button>
  );
}

function StatCard({ title, value, icon, bg, alert=false }: { title: string, value: string, icon: any, bg: string, alert?: boolean }) {
  return (
    <div className={`p-6 rounded-[2rem] bg-white border ${alert ? 'border-red-200 shadow-red-100/50' : 'border-gray-100'} shadow-[0_8px_30px_rgb(0,0,0,0.04)] flex items-start gap-4`}>
      <div className={`w-14 h-14 rounded-2xl ${bg} flex items-center justify-center shrink-0`}>
        {icon}
      </div>
      <div>
        <p className="text-sm text-gray-500 font-medium mb-1">{title}</p>
        <h3 className="text-3xl font-bold tracking-tight text-gray-900">{value}</h3>
      </div>
    </div>
  );
}

function Badge({ text, color='gray' }: { text: string, color?: 'gray'|'green'|'red' }) {
  const styles = {
    gray: 'bg-gray-100 text-gray-700',
    green: 'bg-green-100 text-green-700',
    red: 'bg-red-100 text-red-700',
  };
  return (
    <span className={`px-3 py-1 rounded-full text-xs font-bold tracking-wide uppercase ${styles[color]}`}>
      {text}
    </span>
  );
}
