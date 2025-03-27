//
//  GenerationViewController.swift
//  PASSWD
//
//  Created by Elias Baroudi on 19/03/2025.
//

import UIKit

class GenerationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
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
    var motdepasse: String = ""
    var complexiteMotdepasse: Double = 0.0
    
    
    // Switchs
    @IBOutlet weak var switchSeparateur: UISwitch!
    @IBOutlet weak var switchPhonetique: UISwitch!
    
    
    @IBOutlet var switchMdp: [UISwitch]!
 
    
    // Boutons
    
    @IBAction func refresh(_ sender: Any) {
        genererMotDePasse()
    }
    
    
    // UI
    @IBOutlet weak var sousVue1: UIView!
    @IBOutlet weak var sousVue2: UIView!
    
    @IBOutlet weak var barMdpVue: UIView! // Changer la couleur selon la robustesse du mdp
    
    
    // Complexité du mdp en nombre
    @IBOutlet weak var complexiteMdp: UILabel!
    
    @IBOutlet weak var mdpVue: UIView!
    
    @IBOutlet weak var textMotdepasse: UITextView!
    
    @IBAction func onChangeSwitch(_ sender: UISwitch) {
        for sw in switchMdp {
            print("Switch \(sw.tag) : \(sw.isOn ? "ON" : "OFF")")
        }

        genererMotDePasse()
    }
    


        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI etat de base
        pickerSeparateur.isHidden = true
        pickerEspacement.isHidden = true
        
        
        
        // PickerView
        // Assigner les pickerView au delegate et dataSource

        pickerLongueur.delegate = self
        pickerLongueur.dataSource = self
        
        pickerSeparateur.delegate = self
        pickerSeparateur.dataSource = self
        
        pickerEspacement.delegate = self
        pickerEspacement.dataSource = self
        
        
        // Switch
        // Etat actuel
        switchSeparateur.isOn = false
        updateUISwitchSeparateur(isSwitchOn: false)
        switchSeparateur.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        switchPhonetique.isOn = false
        updateUISwitchPhonetique(isSwitchOn: false)
        switchPhonetique.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        
    }
    
    override func viewDidLayoutSubviews() { // Aryaa SK Coding - YouTube
        sousVue1.layer.cornerRadius = 10
        sousVue1.translatesAutoresizingMaskIntoConstraints = true
        
        sousVue2.layer.cornerRadius = 10
        sousVue2.translatesAutoresizingMaskIntoConstraints = true
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
            // print("🔍 Affichage pickerEspacement : \(nombreEspacement[row])")
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
    
    
    
    
    // Switch
    
    
    // Fonction appelée quand l'utilisateur change l'état du switch
    
    @objc func switchChanged(_ sender: UISwitch) {
        switch sender {
            case switchSeparateur:
                updateUISwitchSeparateur(isSwitchOn: sender.isOn)
                
            case switchPhonetique:
                updateUISwitchPhonetique(isSwitchOn: sender.isOn)

            
            default:
                break
            }
        genererMotDePasse()
        
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
        
    }
    
    // Change l'opacité quand le phonétique est activé
    func updateUISwitchPhonetique(isSwitchOn: Bool) {
        sousVue1.alpha = isSwitchOn ? 0.5 : 1.0 // Change l'opacité pour montrer la désactivation
        sousVue2.alpha = isSwitchOn ? 0.5 : 1.0
        sousVue1.isUserInteractionEnabled = !isSwitchOn // Désactive l'interaction si activé
        sousVue2.isUserInteractionEnabled = !isSwitchOn
    }

    
    
    
    
    
    // Générateur mot de passe
    
    func genererMotDePasse() {
        var base = 0
        var caracteres = [Character]() // Initialisation

        if switchMdp[2].isOn {
            caracteres += symboles
            base += 22 }
        if switchMdp[3].isOn {
            caracteres += majuscules
            base += 26}
        if switchMdp[1].isOn {
            caracteres += chiffres
            base += 10}
        if switchMdp[0].isOn {
            caracteres += minuscules
            base += 26
        }

        // Vérifier si au moins une catégorie est sélectionnée
        guard !caracteres.isEmpty else {
            textMotdepasse.text = "Sélectionnez au moins une option !"
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
            
            arrondiE = round(100*E)/100
            complexiteMdp.text = String(arrondiE) + " bits"
            
        } else {
            E = Double(longueur) * log2(Double(base))
            arrondiE = round(100*E)/100
            complexiteMdp.text = String(arrondiE) + " bits"
        }
    }
    
    
    
    // Reste à faire : garantir qu'une option soit bien dans le mdp.
}
