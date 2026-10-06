import { useState } from 'react';
import { supabase } from '../supabase';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Mail, ArrowLeft, CheckCircle2 } from 'lucide-react';

export default function ForgotPassword() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  const handleReset = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setMessage('');

    try {
      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: window.location.origin + '/update-password',
      });
      
      if (error) throw error;
      
      setSuccess(true);
      setMessage('Un lien de réinitialisation a été envoyé à votre adresse e-mail.');
    } catch (err: any) {
      setError(err.message || 'Une erreur est survenue.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#FBFBFD] font-sans p-6">
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md bg-white p-10 rounded-[2.5rem] shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-100"
      >
        <Link to="/login" className="inline-flex items-center gap-2 text-gray-500 hover:text-gray-900 transition-colors mb-8">
          <ArrowLeft size={20} />
          <span className="font-medium text-sm">Retour</span>
        </Link>

        <h1 className="text-3xl font-bold tracking-tight text-gray-900 mb-2">Mot de passe oublié ?</h1>
        <p className="text-gray-500 font-light mb-8">Entrez votre adresse e-mail pour recevoir un lien de réinitialisation.</p>

        {error && (
          <div className="bg-red-50 text-red-600 p-4 rounded-2xl mb-6 text-sm font-medium">
            {error}
          </div>
        )}

        {success ? (
          <div className="text-center py-6">
            <div className="w-16 h-16 bg-green-50 rounded-full flex items-center justify-center mx-auto mb-4">
              <CheckCircle2 size={32} className="text-green-500" />
            </div>
            <p className="text-gray-900 font-medium">{message}</p>
          </div>
        ) : (
          <form onSubmit={handleReset} className="space-y-5">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Adresse e-mail</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400">
                  <Mail size={20} />
                </div>
                <input 
                  type="email" 
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  className="w-full pl-12 pr-4 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
                  placeholder="admin@boutique.com"
                  required
                />
              </div>
            </div>

            <button type="submit" disabled={loading} className="w-full bg-gray-900 text-white rounded-2xl py-4 font-medium hover:bg-gray-800 active:scale-[0.98] transition-all shadow-md mt-4 disabled:opacity-50">
              {loading ? 'Envoi en cours...' : 'Envoyer le lien'}
            </button>
          </form>
        )}
      </motion.div>
    </div>
  );
}
