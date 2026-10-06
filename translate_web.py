import os

# 1. Landing.tsx (French + Enhanced Apple Design)
landing_code = """import { motion } from 'framer-motion';
import { ArrowRight, Box, BarChart3, Cloud, Download } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function Landing() {
  const containerVariants = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: { staggerChildren: 0.2 }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0, transition: { duration: 0.6, ease: [0.16, 1, 0.3, 1] } }
  };

  return (
    <div className="min-h-screen flex flex-col bg-[#FBFBFD] overflow-hidden">
      {/* Background glow effects */}
      <div className="absolute top-[-20%] left-[-10%] w-[50%] h-[50%] bg-yellow-100 rounded-full blur-[120px] opacity-60 pointer-events-none" />
      <div className="absolute top-[20%] right-[-10%] w-[40%] h-[40%] bg-orange-50 rounded-full blur-[120px] opacity-60 pointer-events-none" />

      {/* Navbar */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-white/70 backdrop-blur-xl border-b border-gray-200/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 bg-gradient-to-tr from-yellow-400 to-yellow-300 rounded-xl flex items-center justify-center shadow-sm">
              <span className="font-bold text-white text-xl">Y</span>
            </div>
            <span className="text-xl font-bold tracking-tight text-gray-900">Yellow Pos</span>
          </div>
          <div className="flex items-center gap-6 text-sm font-medium">
            <Link to="/login" className="text-gray-500 hover:text-gray-900 transition-colors">Se connecter</Link>
            <Link to="/register" className="bg-gray-900 text-white px-5 py-2 rounded-full hover:bg-gray-800 transition-all hover:scale-105 active:scale-95 shadow-md hover:shadow-lg">
              Commencer
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <main className="flex-1 pt-32 pb-24 relative z-10">
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center pt-10 md:pt-20">
          <motion.div initial="hidden" animate="show" variants={containerVariants}>
            <motion.h1 
              variants={itemVariants}
              className="text-6xl md:text-8xl font-bold tracking-tighter text-[#1D1D1F] mb-6 leading-tight"
            >
              La caisse qui fonctionne,<br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 to-yellow-600">tout simplement.</span>
            </motion.h1>
            
            <motion.p 
              variants={itemVariants}
              className="text-xl md:text-2xl text-[#86868B] max-w-2xl mx-auto mb-10 font-light tracking-tight"
            >
              Gérez votre boutique, suivez vos ventes et synchronisez tout dans le cloud. Conçu pour le hors-ligne, connecté en permanence.
            </motion.p>
            
            <motion.div 
              variants={itemVariants}
              className="flex flex-col sm:flex-row items-center justify-center gap-4"
            >
              <Link to="/register" className="bg-gray-900 text-white px-8 py-4 rounded-full text-lg font-medium hover:bg-gray-800 transition-all shadow-lg hover:shadow-xl flex items-center gap-2 hover:scale-105 active:scale-95">
                Créer ma Boutique <ArrowRight size={20} />
              </Link>
              <a href="#" className="bg-white/80 backdrop-blur-md text-gray-900 border border-gray-200 px-8 py-4 rounded-full text-lg font-medium hover:bg-gray-50 transition-all flex items-center gap-2 shadow-sm hover:shadow hover:scale-105 active:scale-95">
                <Download size={20} /> Télécharger l'App
              </a>
            </motion.div>
          </motion.div>
        </section>

        {/* Feature Grid */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-32 md:mt-48 relative z-10">
          <motion.div 
            initial="hidden"
            whileInView="show"
            viewport={{ once: true, margin: "-100px" }}
            variants={containerVariants}
            className="grid md:grid-cols-3 gap-8"
          >
            <FeatureCard 
              icon={<Cloud className="w-8 h-8 text-yellow-500" />}
              title="Hors-ligne d'abord."
              description="Continuez à vendre même sans internet. Vos données se synchronisent automatiquement dès le retour de la connexion."
            />
            <FeatureCard 
              icon={<Box className="w-8 h-8 text-yellow-500" />}
              title="Gestion Magique."
              description="Suivi des stocks en temps réel, scan de codes-barres et alertes de rupture directement sur votre tableau de bord."
            />
            <FeatureCard 
              icon={<BarChart3 className="w-8 h-8 text-yellow-500" />}
              title="Analyses Pro."
              description="Des graphiques superbes et des indicateurs précis pour vous aider à comprendre votre activité et prendre de meilleures décisions."
            />
          </motion.div>
        </section>
      </main>
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode, title: string, description: string }) {
  const itemVariants = {
    hidden: { opacity: 0, y: 30 },
    show: { opacity: 1, y: 0, transition: { duration: 0.8, ease: [0.16, 1, 0.3, 1] } }
  };

  return (
    <motion.div 
      variants={itemVariants}
      whileHover={{ y: -8, scale: 1.02 }}
      transition={{ duration: 0.3 }}
      className="bg-white/80 backdrop-blur-xl p-8 rounded-[2rem] shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-100/50 flex flex-col items-center text-center"
    >
      <div className="w-16 h-16 bg-gradient-to-br from-yellow-50 to-orange-50 rounded-2xl flex items-center justify-center mb-6 shadow-sm border border-yellow-100/50">
        {icon}
      </div>
      <h3 className="text-2xl font-semibold mb-3 tracking-tight text-gray-900">{title}</h3>
      <p className="text-[#86868B] leading-relaxed font-light">{description}</p>
    </motion.div>
  );
}
"""
with open('web-admin/src/pages/Landing.tsx', 'w', encoding='utf-8') as f:
    f.write(landing_code)

# 2. Login.tsx
login_code = """import { useState } from 'react';
import { supabase } from '../supabase';
import { Link, useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setLoading(false);
    if (error) {
      alert(error.message);
    } else {
      navigate('/dashboard');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#FBFBFD] px-4 overflow-hidden relative">
      <div className="absolute top-[10%] left-[20%] w-[40%] h-[40%] bg-yellow-100/50 rounded-full blur-[100px] pointer-events-none" />
      
      <motion.div 
        initial={{ opacity: 0, y: 20, scale: 0.98 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
        className="w-full max-w-md bg-white/80 backdrop-blur-2xl p-10 rounded-[2.5rem] shadow-[0_8px_40px_rgb(0,0,0,0.06)] border border-gray-100 relative z-10"
      >
        <div className="text-center mb-10">
          <div className="w-14 h-14 bg-gradient-to-tr from-yellow-400 to-yellow-300 rounded-[1.25rem] flex items-center justify-center mx-auto mb-6 shadow-md shadow-yellow-200/50">
            <span className="font-bold text-white text-3xl">Y</span>
          </div>
          <h1 className="text-3xl font-bold tracking-tight text-gray-900">Bon retour</h1>
          <p className="text-gray-500 mt-2 font-light">Connectez-vous à votre portail Yellow Pos</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-5">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Adresse e-mail</label>
            <input 
              type="email" 
              value={email}
              onChange={e => setEmail(e.target.value)}
              className="w-full px-5 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
              placeholder="nom@boutique.com"
              required 
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Mot de passe</label>
            <input 
              type="password" 
              value={password}
              onChange={e => setPassword(e.target.value)}
              className="w-full px-5 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
              placeholder="••••••••"
              required 
            />
          </div>
          <button 
            type="submit" 
            disabled={loading}
            className="w-full bg-gray-900 text-white rounded-2xl py-4 font-medium hover:bg-gray-800 active:scale-[0.98] transition-all shadow-md mt-6 disabled:opacity-50"
          >
            {loading ? 'Connexion en cours...' : 'Se connecter'}
          </button>
        </form>

        <p className="text-center mt-10 text-gray-500 text-sm">
          Vous n'avez pas encore de boutique ? <Link to="/register" className="text-yellow-600 font-semibold hover:underline">En créer une</Link>
        </p>
      </motion.div>
    </div>
  );
}
"""
with open('web-admin/src/pages/Login.tsx', 'w', encoding='utf-8') as f:
    f.write(login_code)

# 3. Register.tsx
register_code = """import { useState } from 'react';
import { supabase } from '../supabase';
import { Link, useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';

export default function Register() {
  const [boutiqueName, setBoutiqueName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const { data: authData, error: authError } = await supabase.auth.signUp({ email, password });
      if (authError) throw authError;

      const { data: boutiqueData, error: boutiqueError } = await supabase
        .from('boutiques')
        .insert([{ name: boutiqueName }])
        .select()
        .single();
      if (boutiqueError) throw boutiqueError;

      if (authData.user) {
        await supabase.from('profiles').insert([{
          id: authData.user.id,
          boutique_id: boutiqueData.id,
          role: 'admin'
        }]);
      }

      alert('Inscription réussie !');
      navigate('/login');
    } catch (err: any) {
      alert(err.message || 'Une erreur est survenue.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#FBFBFD] px-4 py-12 relative overflow-hidden">
      <div className="absolute bottom-[10%] right-[10%] w-[50%] h-[50%] bg-orange-100/40 rounded-full blur-[120px] pointer-events-none" />

      <motion.div 
        initial={{ opacity: 0, y: 20, scale: 0.98 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
        className="w-full max-w-md bg-white/80 backdrop-blur-2xl p-10 rounded-[2.5rem] shadow-[0_8px_40px_rgb(0,0,0,0.06)] border border-gray-100 relative z-10"
      >
        <div className="text-center mb-10">
          <div className="w-14 h-14 bg-gradient-to-tr from-yellow-400 to-yellow-300 rounded-[1.25rem] flex items-center justify-center mx-auto mb-6 shadow-md shadow-yellow-200/50">
            <span className="font-bold text-white text-3xl">Y</span>
          </div>
          <h1 className="text-3xl font-bold tracking-tight text-gray-900">Créez votre Boutique</h1>
          <p className="text-gray-500 mt-2 font-light">Démarrez avec Yellow Pos en quelques secondes</p>
        </div>

        <form onSubmit={handleRegister} className="space-y-5">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Nom de la Boutique</label>
            <input 
              type="text" 
              value={boutiqueName}
              onChange={e => setBoutiqueName(e.target.value)}
              className="w-full px-5 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
              placeholder="Ma Super Boutique"
              required 
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">E-mail Administrateur</label>
            <input 
              type="email" 
              value={email}
              onChange={e => setEmail(e.target.value)}
              className="w-full px-5 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
              placeholder="nom@boutique.com"
              required 
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Mot de passe sécurisé</label>
            <input 
              type="password" 
              value={password}
              onChange={e => setPassword(e.target.value)}
              className="w-full px-5 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
              placeholder="••••••••"
              required 
            />
          </div>
          <button 
            type="submit" 
            disabled={loading}
            className="w-full bg-gray-900 text-white rounded-2xl py-4 font-medium hover:bg-gray-800 active:scale-[0.98] transition-all shadow-md mt-8 disabled:opacity-50"
          >
            {loading ? 'Création en cours...' : 'Créer le compte'}
          </button>
        </form>

        <p className="text-center mt-10 text-gray-500 text-sm">
          Vous avez déjà un compte ? <Link to="/login" className="text-yellow-600 font-semibold hover:underline">Se connecter</Link>
        </p>
      </motion.div>
    </div>
  );
}
"""
with open('web-admin/src/pages/Register.tsx', 'w', encoding='utf-8') as f:
    f.write(register_code)

# 4. Dashboard.tsx (French)
dashboard_code = """import { useEffect, useState } from 'react';
import { supabase } from '../supabase';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';

export default function Dashboard() {
  const navigate = useNavigate();
  const [profile, setProfile] = useState<any>(null);

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) {
        navigate('/login');
      } else {
        fetchProfile(user.id);
      }
    });
  }, [navigate]);

  const fetchProfile = async (userId: string) => {
    const { data } = await supabase.from('profiles').select('*, boutiques(name)').eq('id', userId).single();
    setProfile(data);
  };

  const logout = async () => {
    await supabase.auth.signOut();
    navigate('/');
  };

  if (!profile) return (
    <div className="min-h-screen flex items-center justify-center bg-[#FBFBFD]">
      <div className="w-8 h-8 border-4 border-yellow-400 border-t-transparent rounded-full animate-spin"></div>
    </div>
  );

  return (
    <div className="min-h-screen bg-[#FBFBFD] font-sans">
      <header className="bg-white/80 backdrop-blur-xl border-b border-gray-200/60 h-16 flex items-center justify-between px-8 sticky top-0 z-50">
        <div className="font-bold tracking-tight flex items-center gap-3 text-gray-900 text-lg">
          <div className="w-8 h-8 bg-gradient-to-tr from-yellow-400 to-yellow-300 rounded-lg flex items-center justify-center shadow-sm">
            <span className="text-white">Y</span>
          </div>
          {profile.boutiques?.name}
        </div>
        <button onClick={logout} className="text-sm font-medium text-gray-500 hover:text-gray-900 transition-colors bg-gray-100 px-4 py-2 rounded-full hover:bg-gray-200">
          Se déconnecter
        </button>
      </header>
      
      <main className="p-8 max-w-7xl mx-auto pt-12">
        <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}>
          <h1 className="text-4xl font-bold tracking-tight mb-8 text-gray-900">Tableau de bord</h1>
          
          <div className="bg-white p-10 rounded-[2rem] border border-gray-100 shadow-[0_8px_30px_rgb(0,0,0,0.04)]">
            <h2 className="text-2xl font-semibold mb-4 tracking-tight">Bienvenue, Administrateur</h2>
            <p className="text-[#86868B] mb-8 font-light text-lg">
              Ceci est votre portail d'administration. Vous pourrez bientôt voir toutes vos analyses et vos stocks ici.
            </p>
            
            <div className="bg-gradient-to-r from-yellow-50 to-orange-50 border border-yellow-100/50 p-6 rounded-2xl flex flex-col gap-2">
              <span className="text-sm uppercase tracking-wider font-semibold text-yellow-600">ID de la Boutique</span>
              <code className="text-lg font-mono bg-white px-4 py-2 rounded-xl text-gray-800 shadow-sm border border-yellow-100 inline-block w-fit">
                {profile.boutique_id}
              </code>
              <p className="text-sm text-yellow-800/70 mt-2 font-medium">
                Utilisez cet ID dans l'application de bureau Yellow Pos pour synchroniser votre magasin avec ce tableau de bord cloud.
              </p>
            </div>
          </div>
        </motion.div>
      </main>
    </div>
  );
}
"""
with open('web-admin/src/pages/Dashboard.tsx', 'w', encoding='utf-8') as f:
    f.write(dashboard_code)

print("Translated and enhanced all React pages to French Apple-Style!")
