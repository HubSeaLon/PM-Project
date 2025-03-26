//
//  CalculateurViewController.swift
//  PASSWD
//
//  Created by Elias Baroudi on 25/03/2025.
//

import UIKit

import Foundation
import CryptoKit


class CalculateurViewController: UIViewController {
    
    //let wordlist = Bundle.main.path(forResource: "rockyou", ofType: "txt")

    //let wordlist = String(contentsOfFile: "rockyou", encoding: .utf8)
    
    @IBOutlet weak var dictionnaire: UILabel!
    
    @IBOutlet weak var resultatFond: UIView!
    
    @IBOutlet weak var mdpInput: UITextField!

    @IBOutlet weak var mdpHash: UILabel!
    
    @IBOutlet weak var temps: UILabel!
        
    @IBOutlet weak var scoreBar: UIProgressView!
    
    @IBOutlet weak var score: UILabel!
    
    @IBOutlet weak var msg: UILabel!
    
    var messages_faibles: [String] =
    [
        "Ce mot de passe ? 😂 '12345' serait aussi sécurisé...",
        "Un hacker en slip pourrait le cracker 🕵️‍♂️",
        "C'est un test pour un robot, pas un défi 🏃‍♂️",
        "Aussi solide qu'une porte en carton 🪑",
        "Même un script pourrait le deviner 🐍",
        "C'est une invitation aux hackers 😜",
        "Un enfant pourrait trouver ça 👶💻"
    ]
    
    var messages_moyen: [String] =
    [
        "Un peu mieux, mais encore facile pour un robot 🤖🔑",
        "C'est solide, mais un peu de magie ferait bien l'affaire ✨",
        "Pas mal, mais il manque un peu de complexité 🧐",
        "Un hacker débutant pourrait toujours le casser 🕵️‍♂️",
        "C'est mieux, mais pas encore une forteresse 💪",
        "Ajoute un peu de 'twist' 🔮",
        "Ça tient, mais un peu de fantaisie serait top 🎩✨"
    ]
    
    var messages_forts: [String] =
    [
        "Hacker ? Quel hacker ? 💣🔒",
        "C'est une forteresse numérique 🏰🔒",
        "Imbattable, sauf un ordinateur quantique 😏",
        "Même les super-héros des hackers abandonnent 🦸‍♂️💥",
        "Un coffre-fort en acier inoxydable 🔐🛡️",
        "Même les IA galèrent 🤖💥",
        "Tant que tu n'ajoutes pas '12345' 💪🔐",
        "Un château fort avec un dragon 🏰🐉"
    ]
    
    var messages_impossibles: [String] =
    [
        "Pas sûr qu'un ordinateur quantique casse ça 🤯⚛️",
        "Les hackers du futur s'inclinent 👾🔒",
        "Une décennie pour un ordinateur quantique 💻⚡🕰️",
        "Même les hackers n'oseraient pas 😎🔐",
        "Digne des secrets gouvernementaux 🔐👑💼",
        "Un super-ordinateur quantique hésiterait 🤖💡⚛️",
        "Même 1000 ordinateurs quantiques ne peuvent pas 💥⚡💻"
    ]
    
    // Fonction calcul du hash
    func MD5(string: String) -> String {
        let data = Data(string.utf8)  // Convertir la chaîne en données
        let hashed = Insecure.MD5.hash(data: data)  // Calculer le hash MD5
        return hashed.map { String(format: "%02hhx", $0) }.joined()  // Convertir le hash en chaîne hexadécimale
    }
    
    // Calcul du score (bits) de robustesse pour un mdp
    func complexiteMdp (mdp:String,  _ separateur: Bool, _ k: Int = 0) -> (Double) {
        
        var base = 0
        
        var maj: Bool = false
        var min: Bool = false
        var nb: Bool = false
        var sym: Bool = false
        
        var tabInput: [Character] = Array(mdp)
        
        // Analyser le contenu du mot de passe
        if mdp == "" {
            return 0
        }
        
        for char in tabInput {
            if let asciiValue = char.asciiValue, asciiValue >= 65 && asciiValue <= 90 { // le mdp contient t-il des majsucules ?
                maj = true
                base += 26
            }
            
            if let asciiValue = char.asciiValue, asciiValue >= 97 && asciiValue <= 122 { // le mdp contient t-il des minuscules ?
                min = true
                base += 26
            }
            
            if let asciiValue = char.asciiValue, asciiValue >= 48 && asciiValue <= 57 { // le mdp contient t-il des chiffres ?
                nb = true
                base += 10
            }
            
            if let asciiValue = char.asciiValue, asciiValue >= 33 && asciiValue <= 47 { // le mdp contient t-il des symboles ?
                sym = true
                base += 22
            }
            
            // Calcul de la base en fonction de ce que contient le mot de passe
            
            if maj {
                base += 26
            }
            
            if min {
                base += 26
            }
            
            if nb {
                base += 10
            }
            
            if sym {
                base += 22
            }
            
        }
        
        var longueur =  mdp.count

        var E: Double = 0.0
        var arrondiE: Double = 0.0
        
        if (separateur) {
            var coefBinomial: Double = 1.0
            
            for i in 0..<k {
                coefBinomial *= (Double(longueur-1) - Double(i))
                coefBinomial /= (Double(i) + 1)
            }
            
            E = Double(longueur) * log2(Double(base)) + log2(Double(k)) + log2(coefBinomial)
            
        } else {
            E = Double(longueur) * log2(Double(base))
        }
        
        arrondiE = round(100*E)/100
        return arrondiE
    }
    
    // Calcul du temps nécessaire pour cracker un mdp
    func tempsCrack (string: String) -> (String,String) {
        
        var echelle: String
        
        var E: Double = 0.0
        var arrondiE: Double = 0.0
        
        var temps: Double
        var bits: Double
        
        bits = complexiteMdp(mdp: string, false) // Calcul du score de robustesse du mdp avec Separateurs en off
        
        temps = pow(2, bits)/1000000000
        //if (temps == nan) {temps = 0}
    
        // Formater le temps selon l'echelle (secondes, mniutes, heureus...)
        

        
        var sDansAnnees = 60*60*24*365
        
        switch temps {
        case ..<60:
            echelle = " s"  // secondes
        case 60..<60*60:
            echelle = " min"  // minutes
            temps = temps / 60  // Conversion en minutes
        case 60*60..<60*60*24:
            echelle = " h"  // heures
            temps = temps / (60 * 60)  // Conversion en heures
        case 60*60*24..<60*60*24*365:
            echelle = " jours"  // jours
            temps = temps / (60 * 60 * 24)  // Conversion en jours
        case Double(sDansAnnees)..<Double(sDansAnnees*100000000):
            echelle = " années"  // années
            temps = temps / (60 * 60 * 24 * 365)  // Conversion en années
        default:
            echelle = " années"
            temps = temps / (60 * 60 * 24 * 365)
            temps = Double(Int.max)  // Valeur infinie ou une valeur indiquant une erreur
            return (String(temps),echelle) // Cela nous permet d'eviter d'avoir un overflow avec le type Int (on attend de très grandes valeurs)
        }
        
        print(temps)
        return (String(Int(temps)),echelle)
        
    }
    
    func verifierWordlist(_ mdp: String) -> Bool { // StackOverflow
        
        // Cherche l'URL du fichier dans le bundle de l'application
        if let fileURL = Bundle.main.url(forResource: "seclist", withExtension: "txt") {
            // Lire le contenu du fichier
            do {
                let contenu = try String(contentsOf: fileURL, encoding: .isoLatin1)
                
                if contenu.contains(mdp) {
                    return true
                }
            } catch {
                print("Erreur lors de la lecture du fichier : \(error.localizedDescription)")
            }
        } else {
            print("Le fichier n'a pas été trouvé dans le bundle.")
        }
        
        return false
    }
    
    var mdp: String = ""
    
    @IBAction func affichageDynamique(_ sender: UITextField) {

        if sender.text != "" { // verification que le champ n'est pas vide
            mdp = sender.text!
        }
        
        print("calcul..")
        
        // Calcul du Hash du mot de passe
        mdpHash.text = MD5(string: mdp)
        
        // Calcul du temps necessaire pour cracker
        var result = tempsCrack(string: mdp)
        temps.text = result.0 + result.1
        
         // Calcul de la robustesse (bits)
        var progress = complexiteMdp(mdp: mdp, false)
        score.text = String(progress) + " bits"
        
        
        // On change la couleur et la progression de la progresBar selon la robustesse
        
        progress = (progress * 100)/150 // Caclul pour obtenir un porcentage selon la progress bar
        scoreBar.progress = (Float(progress))/100
            
        switch scoreBar.progress {
        case 0...0.2:
            resultatFond.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2) // Couleur du fond
            temps.textColor = UIColor.red // Couleur du texte temps
            scoreBar.progressTintColor = UIColor.red // Couleur de la progressBar
            msg.text = messages_faibles[Int.random(in: 0...2)] // Choix du message
        
        case 0.2...0.6:
            resultatFond.backgroundColor = UIColor(red: 1.0, green: 0.65, blue: 0.0, alpha: 0.2)
            temps.textColor = UIColor.orange
            scoreBar.progressTintColor = UIColor.orange
            msg.text = messages_moyen[Int.random(in: 0...2)]
            
        case 0.6...0.8:
            resultatFond.backgroundColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 0.2)
            temps.textColor = UIColor.green
            scoreBar.progressTintColor = UIColor.green
            msg.text = messages_moyen[Int.random(in: 0...2)]
            
        default:
            resultatFond.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 0.2)
            temps.textColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
            scoreBar.progressTintColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
            msg.text = messages_impossibles[Int.random(in: 0...2)]
        }
        
        
    }
        
    @IBAction func wordList(_ sender: Any) { // Fonction pour faire appel à la liste de 
        
        if verifierWordlist(mdp){
            dictionnaire.text = "Oui ⚠️"
            dictionnaire.textColor = UIColor.red
        }else{
            dictionnaire.text = "Non"
            dictionnaire.textColor = UIColor.green
        }
        
    }
    override func viewDidLoad() {

        super.viewDidLoad()
        affichageDynamique(mdpInput) // On lance la vue avec un champ vide pour initialiser les labels et la barre de score
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
