import { useState } from 'react';
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
