import { useState } from 'react';
import { supabase } from '../supabase';
import { Link, useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { Store, User, CheckCircle2, ChevronRight, ArrowLeft } from 'lucide-react';

export default function Register() {
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  // Admin Data
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  
  // Boutique Data
  const [boutiqueName, setBoutiqueName] = useState('');
  const [phone, setPhone] = useState('');
  const [currency, setCurrency] = useState('USD');

  const handleNext = (e: React.FormEvent) => {
    e.preventDefault();
    setStep(step + 1);
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const { data: authData, error: authError } = await supabase.auth.signUp({ email, password });
      if (authError) throw authError;

      const { data: boutiqueData, error: boutiqueError } = await supabase
        .from('boutiques')
        .insert([{ 
          name: boutiqueName,
          phone: phone,
          currency: currency
        }])
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

      setStep(3); // Success Step
    } catch (err: any) {
      alert(err.message || 'Une erreur est survenue.');
    } finally {
      setLoading(false);
    }
  };

  const variants = {
    initial: (direction: number) => ({ x: direction > 0 ? 50 : -50, opacity: 0 }),
    animate: { x: 0, opacity: 1, transition: { duration: 0.4 } },
    exit: (direction: number) => ({ x: direction > 0 ? -50 : 50, opacity: 0, transition: { duration: 0.3 } })
  };

  return (
    <div className="min-h-screen flex bg-white font-sans overflow-hidden">
      {/* Left Pane - Branding */}
      <div className="hidden lg:flex lg:w-5/12 bg-gray-50 flex-col justify-between relative p-12 overflow-hidden border-r border-gray-100">
        <div className="absolute top-[-10%] left-[-20%] w-[80%] h-[60%] bg-yellow-200/50 rounded-full blur-[120px] pointer-events-none" />
        <div className="absolute bottom-[-10%] right-[-20%] w-[60%] h-[60%] bg-orange-200/30 rounded-full blur-[120px] pointer-events-none" />
        
        <div className="relative z-10">
          <Link to="/" className="flex items-center gap-3 w-fit">
            <div className="w-10 h-10 bg-gradient-to-tr from-yellow-400 to-yellow-300 rounded-xl flex items-center justify-center shadow-sm">
              <span className="font-bold text-white text-xl">Y</span>
            </div>
            <span className="text-xl font-bold tracking-tight text-gray-900">Yellow Pos</span>
          </Link>
        </div>

        <div className="relative z-10 mb-20">
          <h2 className="text-4xl font-bold tracking-tight text-gray-900 mb-6 leading-tight">
            La gestion de votre boutique,<br/>élevée au niveau supérieur.
          </h2>
          <p className="text-lg text-gray-500 font-light mb-8 max-w-md">
            Rejoignez des centaines de commerçants qui simplifient leurs ventes quotidiennes, sans dépendre d'internet.
          </p>
          
          <div className="space-y-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-full bg-white shadow-sm flex items-center justify-center text-yellow-500">
                <CheckCircle2 size={24} />
              </div>
              <p className="font-medium text-gray-700">Synchronisation Cloud Sécurisée</p>
            </div>
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-full bg-white shadow-sm flex items-center justify-center text-yellow-500">
                <CheckCircle2 size={24} />
              </div>
              <p className="font-medium text-gray-700">Multi-devises Natif (USD/CDF)</p>
            </div>
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-full bg-white shadow-sm flex items-center justify-center text-yellow-500">
                <CheckCircle2 size={24} />
              </div>
              <p className="font-medium text-gray-700">Fonctionnement 100% Hors-ligne</p>
            </div>
          </div>
        </div>
      </div>

      {/* Right Pane - Form Wizard */}
      <div className="w-full lg:w-7/12 flex items-center justify-center p-6 relative">
        <div className="w-full max-w-md relative">
          
          {/* Header */}
          <div className="mb-10 text-center lg:text-left">
            {step < 3 && (
              <div className="flex items-center justify-center lg:justify-start gap-2 mb-6">
                <div className={`h-2 flex-1 rounded-full ${step >= 1 ? 'bg-yellow-400' : 'bg-gray-100'}`} />
                <div className={`h-2 flex-1 rounded-full ${step >= 2 ? 'bg-yellow-400' : 'bg-gray-100'}`} />
                <div className="h-2 flex-1 rounded-full bg-gray-100" />
              </div>
            )}
            <h1 className="text-3xl font-bold tracking-tight text-gray-900 mb-2">
              {step === 1 && "Créer votre compte"}
              {step === 2 && "Détails de la boutique"}
              {step === 3 && "C'est prêt !"}
            </h1>
            <p className="text-gray-500 font-light">
              {step === 1 && "Entrez vos informations d'administrateur principal."}
              {step === 2 && "Configurez l'environnement de votre commerce."}
              {step === 3 && "Votre espace a été créé avec succès."}
            </p>
          </div>

          {/* Form Area */}
          <div className="relative">
            <AnimatePresence mode="wait" custom={1}>
              
              {/* STEP 1 */}
              {step === 1 && (
                <motion.form 
                  key="step1" custom={1} variants={variants} initial="initial" animate="animate" exit="exit"
                  onSubmit={handleNext} className="space-y-5"
                >
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Adresse e-mail</label>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400">
                        <User size={20} />
                      </div>
                      <input 
                        type="email" 
                        value={email}
                        onChange={e => setEmail(e.target.value)}
                        className="w-full pl-12 pr-4 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
                        placeholder="admin@boutique.com"
                        required autoFocus
                      />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Mot de passe sécurisé</label>
                    <input 
                      type="password" 
                      value={password}
                      onChange={e => setPassword(e.target.value)}
                      className="w-full px-5 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
                      placeholder="••••••••"
                      required minLength={6}
                    />
                  </div>
                  <button type="submit" className="w-full bg-gray-900 text-white rounded-2xl py-4 font-medium hover:bg-gray-800 active:scale-[0.98] transition-all shadow-md mt-6 flex items-center justify-center gap-2">
                    Continuer <ChevronRight size={20} />
                  </button>
                  <p className="text-center mt-6 text-gray-500 text-sm">
                    Vous avez déjà un compte ? <Link to="/login" className="text-yellow-600 font-semibold hover:underline">Se connecter</Link>
                  </p>
                </motion.form>
              )}

              {/* STEP 2 */}
              {step === 2 && (
                <motion.form 
                  key="step2" custom={1} variants={variants} initial="initial" animate="animate" exit="exit"
                  onSubmit={handleRegister} className="space-y-5"
                >
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Nom de la Boutique</label>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400">
                        <Store size={20} />
                      </div>
                      <input 
                        type="text" 
                        value={boutiqueName}
                        onChange={e => setBoutiqueName(e.target.value)}
                        className="w-full pl-12 pr-4 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
                        placeholder="Ex: SuperMarché Kivu"
                        required autoFocus
                      />
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Téléphone</label>
                      <input 
                        type="tel" 
                        value={phone}
                        onChange={e => setPhone(e.target.value)}
                        className="w-full px-5 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
                        placeholder="+243..."
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Devise Principale</label>
                      <select 
                        value={currency}
                        onChange={e => setCurrency(e.target.value)}
                        className="w-full px-5 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all appearance-none"
                      >
                        <option value="USD">Dollar (USD)</option>
                        <option value="CDF">Franc Congolais (CDF)</option>
                      </select>
                    </div>
                  </div>

                  <div className="flex items-center gap-3 mt-8">
                    <button type="button" onClick={() => setStep(1)} className="w-14 h-14 rounded-2xl border border-gray-200 flex items-center justify-center text-gray-600 hover:bg-gray-50 transition-colors">
                      <ArrowLeft size={20} />
                    </button>
                    <button type="submit" disabled={loading} className="flex-1 bg-gradient-to-r from-yellow-500 to-yellow-400 text-gray-900 rounded-2xl py-4 font-bold hover:shadow-lg hover:shadow-yellow-200 active:scale-[0.98] transition-all disabled:opacity-50 flex items-center justify-center gap-2">
                      {loading ? 'Création en cours...' : 'Terminer la création'}
                    </button>
                  </div>
                </motion.form>
              )}

              {/* STEP 3 - SUCCESS */}
              {step === 3 && (
                <motion.div 
                  key="step3" custom={1} variants={variants} initial="initial" animate="animate" exit="exit"
                  className="text-center py-8"
                >
                  <div className="w-24 h-24 bg-green-50 rounded-full flex items-center justify-center mx-auto mb-6">
                    <CheckCircle2 size={48} className="text-green-500" />
                  </div>
                  <h3 className="text-2xl font-bold text-gray-900 mb-2">Inscription réussie !</h3>
                  <p className="text-gray-500 mb-8 font-light">
                    Votre boutique <strong>{boutiqueName}</strong> est maintenant prête.
                  </p>
                  
                  <div className="space-y-3">
                    <button onClick={() => navigate('/dashboard')} className="w-full bg-gray-900 text-white rounded-2xl py-4 font-medium hover:bg-gray-800 transition-all shadow-md">
                      Accéder au Portail Admin
                    </button>
                    <button className="w-full bg-white border border-gray-200 text-gray-900 rounded-2xl py-4 font-medium hover:bg-gray-50 transition-all">
                      Télécharger l'App Bureau
                    </button>
                  </div>
                </motion.div>
              )}

            </AnimatePresence>
          </div>
        </div>
      </div>
    </div>
  );
}
