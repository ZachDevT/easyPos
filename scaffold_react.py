import os

os.makedirs('web-admin/src/pages', exist_ok=True)

# 1. Landing.tsx
landing_code = """import { motion } from 'framer-motion';
import { ArrowRight, Box, BarChart3, Cloud, Shield } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function Landing() {
  return (
    <div className="min-h-screen flex flex-col">
      {/* Navbar */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-yellow-400 rounded-lg flex items-center justify-center">
              <span className="font-bold text-white text-xl">Y</span>
            </div>
            <span className="text-xl font-bold tracking-tight">Yellow Pos</span>
          </div>
          <div className="flex items-center gap-6 text-sm font-medium">
            <Link to="/login" className="text-gray-600 hover:text-gray-900 transition-colors">Sign In</Link>
            <Link to="/register" className="bg-gray-900 text-white px-5 py-2 rounded-full hover:bg-gray-800 transition-colors">
              Get Started
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <main className="flex-1 pt-32 pb-24">
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.h1 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, ease: "easeOut" }}
            className="text-6xl md:text-8xl font-bold tracking-tighter text-[#1D1D1F] mb-6"
          >
            The POS that <br />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 to-yellow-600">just works.</span>
          </motion.h1>
          
          <motion.p 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2, ease: "easeOut" }}
            className="text-xl md:text-2xl text-[#86868B] max-w-2xl mx-auto mb-10 font-light tracking-tight"
          >
            Manage your boutique, track sales, and sync everything to the cloud. Offline-first, seamlessly connected.
          </motion.p>
          
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.4, ease: "easeOut" }}
            className="flex flex-col sm:flex-row items-center justify-center gap-4"
          >
            <Link to="/register" className="bg-gray-900 text-white px-8 py-4 rounded-full text-lg font-medium hover:bg-gray-800 transition-all shadow-lg hover:shadow-xl flex items-center gap-2">
              Create your Boutique <ArrowRight size={20} />
            </Link>
            <a href="#" className="bg-white text-gray-900 border border-gray-200 px-8 py-4 rounded-full text-lg font-medium hover:bg-gray-50 transition-all flex items-center gap-2">
              Download App
            </a>
          </motion.div>
        </section>

        {/* Feature Grid */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-40">
          <div className="grid md:grid-cols-3 gap-8">
            <FeatureCard 
              icon={<Cloud className="w-8 h-8 text-yellow-500" />}
              title="Offline First."
              description="Keep selling even when the internet drops. Data syncs automatically when you're back online."
            />
            <FeatureCard 
              icon={<Box className="w-8 h-8 text-yellow-500" />}
              title="Inventory Magic."
              description="Real-time stock tracking, barcode scanning, and low-stock alerts right on your dashboard."
            />
            <FeatureCard 
              icon={<BarChart3 className="w-8 h-8 text-yellow-500" />}
              title="Pro Analytics."
              description="Beautiful charts and insights to help you understand your business and make better decisions."
            />
          </div>
        </section>
      </main>
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode, title: string, description: string }) {
  return (
    <motion.div 
      whileHover={{ y: -5 }}
      className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100 flex flex-col items-center text-center"
    >
      <div className="w-16 h-16 bg-yellow-50 rounded-2xl flex items-center justify-center mb-6">
        {icon}
      </div>
      <h3 className="text-xl font-bold mb-3">{title}</h3>
      <p className="text-[#86868B]">{description}</p>
    </motion.div>
  );
}
"""
with open('web-admin/src/pages/Landing.tsx', 'w') as f:
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
    <div className="min-h-screen flex items-center justify-center bg-[#FBFBFD] px-4">
      <motion.div 
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="w-full max-w-md bg-white p-10 rounded-[2rem] shadow-xl border border-gray-100"
      >
        <div className="text-center mb-10">
          <div className="w-12 h-12 bg-yellow-400 rounded-xl flex items-center justify-center mx-auto mb-6 shadow-sm">
            <span className="font-bold text-white text-2xl">Y</span>
          </div>
          <h1 className="text-3xl font-bold tracking-tight">Welcome back</h1>
          <p className="text-gray-500 mt-2">Sign in to your Yellow Pos portal</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Email address</label>
            <input 
              type="email" 
              value={email}
              onChange={e => setEmail(e.target.value)}
              className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:border-transparent transition-all"
              required 
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Password</label>
            <input 
              type="password" 
              value={password}
              onChange={e => setPassword(e.target.value)}
              className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:border-transparent transition-all"
              required 
            />
          </div>
          <button 
            type="submit" 
            disabled={loading}
            className="w-full bg-gray-900 text-white rounded-xl py-4 font-medium hover:bg-gray-800 transition-colors disabled:opacity-50"
          >
            {loading ? 'Signing in...' : 'Sign in'}
          </button>
        </form>

        <p className="text-center mt-8 text-gray-500 text-sm">
          Don't have a boutique yet? <Link to="/register" className="text-yellow-600 font-semibold hover:underline">Create one</Link>
        </p>
      </motion.div>
    </div>
  );
}
"""
with open('web-admin/src/pages/Login.tsx', 'w') as f:
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
      // 1. Create User
      const { data: authData, error: authError } = await supabase.auth.signUp({ 
        email, 
        password 
      });
      
      if (authError) throw authError;

      // 2. Create Boutique
      const { data: boutiqueData, error: boutiqueError } = await supabase
        .from('boutiques')
        .insert([{ name: boutiqueName }])
        .select()
        .single();
        
      if (boutiqueError) throw boutiqueError;

      // 3. Link Profile
      if (authData.user) {
        await supabase.from('profiles').insert([{
          id: authData.user.id,
          boutique_id: boutiqueData.id,
          role: 'admin'
        }]);
      }

      alert('Registration successful! Check your email if confirmation is required.');
      navigate('/login');
    } catch (err: any) {
      alert(err.message || 'An error occurred during registration.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#FBFBFD] px-4 py-12">
      <motion.div 
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="w-full max-w-md bg-white p-10 rounded-[2rem] shadow-xl border border-gray-100"
      >
        <div className="text-center mb-10">
          <div className="w-12 h-12 bg-yellow-400 rounded-xl flex items-center justify-center mx-auto mb-6 shadow-sm">
            <span className="font-bold text-white text-2xl">Y</span>
          </div>
          <h1 className="text-3xl font-bold tracking-tight">Create your Boutique</h1>
          <p className="text-gray-500 mt-2">Get started with Yellow Pos in seconds</p>
        </div>

        <form onSubmit={handleRegister} className="space-y-5">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Boutique Name</label>
            <input 
              type="text" 
              value={boutiqueName}
              onChange={e => setBoutiqueName(e.target.value)}
              className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:border-transparent transition-all"
              required 
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Admin Email</label>
            <input 
              type="email" 
              value={email}
              onChange={e => setEmail(e.target.value)}
              className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:border-transparent transition-all"
              required 
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Secure Password</label>
            <input 
              type="password" 
              value={password}
              onChange={e => setPassword(e.target.value)}
              className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:border-transparent transition-all"
              required 
            />
          </div>
          <button 
            type="submit" 
            disabled={loading}
            className="w-full bg-gray-900 text-white rounded-xl py-4 font-medium hover:bg-gray-800 transition-colors mt-4 disabled:opacity-50"
          >
            {loading ? 'Creating account...' : 'Create Account'}
          </button>
        </form>

        <p className="text-center mt-8 text-gray-500 text-sm">
          Already have an account? <Link to="/login" className="text-yellow-600 font-semibold hover:underline">Sign in</Link>
        </p>
      </motion.div>
    </div>
  );
}
"""
with open('web-admin/src/pages/Register.tsx', 'w') as f:
    f.write(register_code)

# 4. Dashboard Placeholder
dashboard_code = """import { useEffect, useState } from 'react';
import { supabase } from '../supabase';
import { useNavigate } from 'react-router-dom';

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

  if (!profile) return <div className="min-h-screen flex items-center justify-center">Loading...</div>;

  return (
    <div className="min-h-screen bg-[#FBFBFD]">
      <header className="bg-white border-b border-gray-200 h-16 flex items-center justify-between px-8">
        <div className="font-bold tracking-tight flex items-center gap-2">
          <div className="w-8 h-8 bg-yellow-400 rounded-lg flex items-center justify-center">
            <span className="text-white">Y</span>
          </div>
          {profile.boutiques?.name}
        </div>
        <button onClick={logout} className="text-sm font-medium text-gray-500 hover:text-gray-900">Sign Out</button>
      </header>
      <main className="p-8 max-w-7xl mx-auto">
        <h1 className="text-3xl font-bold tracking-tight mb-8">Dashboard</h1>
        <div className="bg-white p-8 rounded-3xl border border-gray-200 shadow-sm">
          <p className="text-gray-500 mb-4">Welcome to your online admin portal. Since you are an admin, you can see all analytics here.</p>
          <div className="bg-yellow-50 text-yellow-800 p-4 rounded-xl text-sm font-medium">
            <strong>Boutique ID:</strong> {profile.boutique_id}
          </div>
          <p className="text-sm text-gray-400 mt-4">
            Use this Boutique ID inside the Yellow Pos Desktop App to sync your local store with this cloud dashboard.
          </p>
        </div>
      </main>
    </div>
  );
}
"""
with open('web-admin/src/pages/Dashboard.tsx', 'w') as f:
    f.write(dashboard_code)

# 5. App.tsx (React Router Setup)
app_code = """import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Landing from './pages/Landing';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Landing />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/dashboard" element={<Dashboard />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
"""
with open('web-admin/src/App.tsx', 'w') as f:
    f.write(app_code)

print("Scaffolded all React pages!")
