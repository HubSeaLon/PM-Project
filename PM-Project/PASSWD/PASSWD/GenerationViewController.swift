//
//  GenerationViewController.swift
//  PASSWD
//
//  Created by Elias Baroudi on 19/03/2025.
//

import UIKit

class GenerationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    // Phonétique
    
    @IBOutlet weak var textPhonetique: UITextField!
    let aP = Array("aàâä")
    let eP = Array("eèêë")
    let iP = Array("iìîï")
    let oP = Array("oòôö")
    let uP = Array("uùûü")
    let espaceP = Array(" -_:;+")
    
    // A faire avec toutes les lettre de l'alphabet ??
    
    
    // Données et initialisation des PickerView
    @IBOutlet weak var pickerLongueur: UIPickerView!
    @IBOutlet weak var pickerSeparateur: UIPickerView!
    @IBOutlet weak var pickerEspacement: UIPickerView!
    
    let nombreLongueur = Array(1...128)
    let typeSeparateur: [Character] = Array("-|!?/*")

    var longueurSelectionnee: Int = 1
    var nombreEspacement: [Int] = []
    var separateurSelectionnee: String = "-"
    var espacementSelectionnee: Int = 1
    
    // Initilisations des données
    let majuscules: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let minuscules: [Character] = Array("abcdefghijklmnopqrstuvwxyz")
    let chiffres = Array("0123456789")
    let symboles = Array("!@#$%*()-_=+[]{};:,./?")
    
    var complexiteMotdepasse: Float = 0.0
    
    
    // Switchs
    @IBOutlet weak var switchSeparateur: UISwitch!
    @IBOutlet weak var switchPhonetique: UISwitch!
    
    @IBOutlet weak var switchMajuscule: UISwitch!
    @IBOutlet weak var switchMinuscule: UISwitch!
    @IBOutlet weak var switchChiffre: UISwitch!
    @IBOutlet weak var switchSymbole: UISwitch!
    
    // Boutons
    
    @IBAction func refresh(_ sender: Any) {
        genererMotDePasse()
    }
    
    
    // UI
    @IBOutlet weak var sousVue1: UIView!
    @IBOutlet weak var sousVue2: UIView!
    
 
    
    // Complexité du mdp en nombre
    @IBOutlet weak var complexiteMdp: UILabel!
    @IBOutlet weak var barComplexite: UIProgressView!
    @IBOutlet weak var motComplexite: UILabel!
    
    @IBOutlet weak var textMotdepasse: UITextView!
    
    @IBOutlet weak var vueMdp: UIView!
    
    
    func initialisationVueMdp() {
        complexiteMdp.text = "0 bits"
        barComplexite.progress = 0.0
        motComplexite.text = "Néant"
        textMotdepasse.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI etat de base
        pickerSeparateur.isHidden = true
        pickerEspacement.isHidden = true
        
        // PickerView
        // Assigner les pickerView au delegate et dataSource

        let pickers: [UIPickerView] = [pickerLongueur, pickerSeparateur, pickerEspacement]
        
        for picker in pickers {
            picker.delegate = self
            picker.dataSource = self
        }
        
        
        // Switch
        // Etat actuel
        switchSeparateur.isOn = false
        updateUISwitchSeparateur(isSwitchOn: false)

        switchPhonetique.isOn = false
        updateUISwitchPhonetique(isSwitchOn: false)

        initialisationVueMdp()
    }
    
    
    override func viewDidLayoutSubviews() { // Aryaa SK Coding - YouTube
        sousVue1.layer.cornerRadius = 10
        sousVue1.translatesAutoresizingMaskIntoConstraints = true
        
        sousVue2.layer.cornerRadius = 10
        sousVue2.translatesAutoresizingMaskIntoConstraints = true
        
        textMotdepasse.layer.borderWidth = 1.0
        textMotdepasse.layer.borderColor = UIColor.gray.cgColor
        textMotdepasse.layer.cornerRadius = 10
        
    }
    
    
    
    
    // Switch
    // Fonction appelée quand l'utilisateur change l'état du switch
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        switch sender {
            case switchSeparateur:
                updateUISwitchSeparateur(isSwitchOn: sender.isOn)
                
            case switchPhonetique:
                updateUISwitchPhonetique(isSwitchOn: sender.isOn)
                
                if sender.isOn {
                    initialisationVueMdp()
                } else {
                    genererMotDePasse()
                }
            
            default:
                genererMotDePasse()
        }
    }
    
    
    // MAJ des éléments si le switchSeparateur est activé
    func updateUISwitchSeparateur(isSwitchOn: Bool){
    
        pickerEspacement.isHidden = !isSwitchOn
        pickerSeparateur.isHidden = !isSwitchOn
        if isSwitchOn {
            pickerEspacement.reloadAllComponents()
            print("Séparateur choisi : \(separateurSelectionnee)")
            print("nombre espacement choisi : \(espacementSelectionnee)")
        }
        genererMotDePasse()
    }
    
    
    
    // Change le visuel quand le phonétique est activé
    func updateUISwitchPhonetique(isSwitchOn: Bool) {
        // Change l'opacité pour montrer la désactivation
        sousVue1.alpha = isSwitchOn ? 0.5 : 1.0
        sousVue2.alpha = isSwitchOn ? 0.5 : 1.0
        // Désactive l'interaction si activé
        sousVue1.isUserInteractionEnabled = !isSwitchOn
        sousVue2.isUserInteractionEnabled = !isSwitchOn
        
        textPhonetique.isEnabled = isSwitchOn ? true : false
    }
    
    
    // Picker View
    
    // Nombre de colonnes
    func numberOfComponents(in pickerLongueur: UIPickerView) -> Int {
        return 1 // 1 seule colonne par picker
    }
    
    // Nombre de ligne selon le picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerLongueur {
            return nombreLongueur.count
            
        } else if pickerView == pickerSeparateur {
            return typeSeparateur.count
        } else if pickerView == pickerEspacement {
            
            // print("pickerEspacement a \(nombreEspacement.count) lignes disponibles")
        
            return pickerView == pickerEspacement ? nombreEspacement.count : 0
        }
        return 0
    }
    
    
    // Affichage des valeurs dans picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerLongueur {
            return "\(nombreLongueur[row])"
        } else if pickerView == pickerSeparateur {
            return String(typeSeparateur[row])
        } else if pickerView == pickerEspacement {
            // print("Affichage pickerEspacement : \(nombreEspacement[row])")
            return "\(nombreEspacement[row])"
        }
        return nil
    }
    
    // Action quand un élément est sélectionné
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerLongueur {
            longueurSelectionnee = nombreLongueur[row]
            if Int(longueurSelectionnee) < 10 {
                pickerSeparateur.isHidden = true
                switchSeparateur.isHidden = true
                switchSeparateur.isHidden = true
                updateUISwitchSeparateur(isSwitchOn: false)
                switchSeparateur.isOn = false
            } else {
                switchSeparateur.isHidden = false
                majEspacement(longueur: longueurSelectionnee)
            }
            
            print("Longueur sélectionnée : \(longueurSelectionnee)")
            
        } else if pickerView == pickerSeparateur {
            separateurSelectionnee = String(typeSeparateur[row])
            print("Sépérateur choisi : \(separateurSelectionnee)")
            
        } else if pickerView == pickerEspacement {
            espacementSelectionnee = nombreEspacement[row]
            print("Nombre séparateur choisi : \(espacementSelectionnee)")
        }
        genererMotDePasse()
    }
    
    // Fonction pour rafraichir dynamiquement le pickerViewEspacement selon la longueur
    func majEspacement(longueur: Int) {
           let nouvelEspacement = Array(1..<longueur)

           if nouvelEspacement == nombreEspacement {
               print("Pas de changement dans    nombreEspacement, pas de reload.")
               return
           }

           nombreEspacement = nouvelEspacement.isEmpty ? [1] : nouvelEspacement
           print("Nouveau espacement : \(nombreEspacement)")

           pickerEspacement.reloadAllComponents()
           pickerEspacement.setNeedsLayout()
    }
    
    

    
    
    // Générateur mot de passe
    
    func genererMotDePasse() {
        var base = 0
        var caracteres = [Character]() // Initialisation
        
        if switchSymbole.isOn {
            caracteres += symboles
            base += 22
        }
        if switchMajuscule.isOn {
            caracteres += majuscules
            base += 26
        }
        if switchChiffre.isOn {
            caracteres += chiffres
            base += 10
        }
        if switchMinuscule.isOn {
            caracteres += minuscules
            base += 26
        }

        // Vérifier si au moins une catégorie est sélectionnée
        guard !caracteres.isEmpty else {
            textMotdepasse.text = "Sélectionnez au moins une option !"
            
            complexiteMdp.text = "0 bits"
            motComplexite.text = "Néant"
            motComplexite.textColor = UIColor.black
            barComplexite.progress = 0.0
            return
        }

        caracteres.shuffle()
        
        var resultat = ""
        var i = 0
        var j = 0
        
        // Ajout du séparateur
        repeat {
            resultat += String(caracteres.randomElement() ?? "x")
            i += 1
            if switchSeparateur.isOn, i % espacementSelectionnee == 0 {
                resultat += separateurSelectionnee
                j += 1
            }
            
        } while (i + j < longueurSelectionnee)

        if resultat.count > longueurSelectionnee {
            resultat.removeLast(resultat.count - longueurSelectionnee)
        }
        
       
        complexiteMdp(Int(longueurSelectionnee), base, 6)
        textMotdepasse.text = resultat
       
    }
    
    
    
    /* Complexité d'un mot de passe : E = L * log2(B)
     
    E : Entreprie en bits
    L : longueur mot de passe (nombre de caractères)
    B : nombre de caractères différents qu'ils peuvent prendre
     
    Cas ou on rajoute les séparateurs la formule deviendrait (Merci GPT):
     
    E = L * log2(B) + log2(k) + log2(C(L-1,k))
    ou k est nombre de séparateurs
    C(L-1,k)) : coefficient binomial du nombre de façon de choisir ou placer le séparateur
    
     
     */
    
    func complexiteMdp (_ longueur: Int, _ base: Int, _ k: Int) {
        var E: Double = 0.0
        var arrondiE: Double = 0.0
        
        
        if switchSeparateur.isOn {
            var coefBinomial: Double = 1.0
            
            for i in 0..<k {
                coefBinomial *= (Double(longueur-1) - Double(i))
                coefBinomial /= (Double(i) + 1)
            }
            
            E = Double(longueur) * log2(Double(base)) + log2(Double(k)) + log2(coefBinomial)
        } else {
            E = Double(longueur) * log2(Double(base))
        }
        
        arrondiE = round(10*E)/10
        complexiteMdp.text = String(arrondiE) + " bits"
        
    
        switch Int(arrondiE) {
        case (0...27):
            motComplexite.textColor = UIColor(ciColor: CIColor(red: 220/225, green: 20/255, blue: 60/255, alpha: 1))
            motComplexite.text = "Très faible"
        case (28...35):
            motComplexite.textColor = UIColor(ciColor: CIColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1))
            motComplexite.text = "Faible"
        case (36...59):
            motComplexite.textColor = UIColor(ciColor: CIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1))
            motComplexite.text = "Moyen"
        case (60...128):
            
            motComplexite.text = "Fort"
            motComplexite.textColor = UIColor(ciColor: CIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1))
        case (127...):
            motComplexite.textColor = UIColor(ciColor: CIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1))
            motComplexite.text = "Très fort"
        default:
            motComplexite.text = "Erreur"
        }
        
        
        // Bar complexité
        
        let i: Int = Int(arrondiE)
        let max: Int = 128
        
        if i <= max {
            let ratio = Float(i) / Float(max)
            barComplexite.progress = ratio
        } else {
            barComplexite.progress = 1.0
        }
    }
    
    
    
    // Reste à faire : garantir qu'une option soit bien dans le mdp.
}
