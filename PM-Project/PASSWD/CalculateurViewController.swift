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

    @IBOutlet weak var mdpInput: UITextField!

    @IBOutlet weak var mdpHash: UILabel!
    
    @IBOutlet weak var temps: UILabel!
    
    @IBOutlet weak var couts: UILabel!
    
    @IBOutlet weak var scoreBar: UIProgressView!
    
    @IBOutlet weak var score: UILabel!
    
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
    func tempsCrack (string: String) -> (Int,String) {
        
        var echelle: String
        
        var E: Double = 0.0
        var arrondiE: Double = 0.0
        
        var temps: Double
        var bits: Double
        
        bits = complexiteMdp(mdp: string, false) // Calcul du score de robustesse du mdp avec Separateurs en off
        
        temps = pow(2, bits)/1000000000
        
        // Formater le temps selon l'echelle (secondes, mniutes, heureus...)
        
        // affichage en secondes
        print(temps)
        
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
        case Double(sDansAnnees)..<Double(sDansAnnees*100):
            echelle = " années"  // années
            temps = temps / (60 * 60 * 24 * 365)  // Conversion en années
        default:
            echelle = " inconnu"
            temps = Double(Int.max)  // Valeur infinie ou une valeur indiquant une erreur
        }
        
        print(Int)
        return (Int(temps),echelle)
    }
    
    @IBAction func affichageDynamique(_ sender: UITextField) {
        var mdp: String = ""

        if sender.text != nil { // verification que le champ n'est pas vide
            mdp = sender.text!
        }
        
        print("calcul..")
        
        // Calcul du Hash du mot de passe
        mdpHash.text = MD5(string: mdp)
        
        // Calcul du temps necessaire pour cracker
         
        var result = tempsCrack(string: mdp)
        temps.text = String(result.0) + result.1
        
         
        var progress = complexiteMdp(mdp: mdp, false)
        score.text = String(progress) + " bits"
        
        progress = (progress * 100)/150
        
        scoreBar.progress = (Float(progress))/100
        
        if scoreBar.progress <= 0.2 { scoreBar.progressTintColor = UIColor.red }
        else if scoreBar.progress <= 0.6 { scoreBar.progressTintColor = UIColor.orange }
        else { scoreBar.progressTintColor = UIColor.green }
        
    }
    
    @IBAction func mdpInputChange(_ sender: UITextField) {
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
