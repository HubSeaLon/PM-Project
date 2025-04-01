//
//  CoffreViewController.swift
//  PASSWD
//
//  Created by Hubert Geoffray on 30/03/2025.
//

import UIKit
import LocalAuthentication  // Pour utiliser Face ID ou empreinte


// Avoir plusieurs cellules sur un meme ligne
// SOurce : stackoverflow.com/questions/59001569/make-tableview-with-multiple-columns

class nCell: UITableViewCell {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
}

extension UILabel {
    func maskTextWithDots() {
        guard let originalText = self.text else { return }
        self.text = String(repeating: "•", count: originalText.count)
    }
}

class CoffreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AjouterMDPDelegate {
    
    @IBOutlet weak var supprimer: UIButton!
    @IBOutlet weak var copier: UIButton!
    @IBOutlet weak var annuler: UIButton!
    
    
    
    // Variables nécessaires à l'ajout de mdp
    var application: String = ""
    var login: String = ""
    var mdp: String = ""
    
    var annule: Bool = false
    
    var nbLignes = 0
    var nbCol = 0
    
    var lines: [String] = []
    
    var ligneSelectionnee: Int?
    
    // Source pour la création de la table UITableView:
    // "www.youtube.com/watch?v=C36sb5sc6lE"
    
    // Fonction qui retourne le nb de lignes dans le tableau
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nbLignes
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Récupérer la ligne
        ligneSelectionnee = indexPath.row
        
        // Récupérer la cellule
        if let cell = tableView.cellForRow(at: indexPath) as? nCell {
            // Diviser la ligne en fonction de la virgule
            let line = lines[indexPath.row].split(separator: ",") // Exemple de séparation par ","

            // Assurez-vous qu'il y a bien 3 éléments dans la ligne
            if line.count > 2 {
                // Afficher le mot de passe en clair dans label3
                cell.label3.text = String(line[2]) // Affiche le mot de passe en clair
            }
            
            supprimer.isHidden = false
            copier.isHidden = false
            annuler.isHidden = false
        }
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Récupérer la cellule
        if let cell = tableView.cellForRow(at: indexPath) as? nCell {
            // Diviser la ligne en fonction de la virgule
            let line = lines[indexPath.row].split(separator: ",") // Exemple de séparation par ","

            // Assurez-vous qu'il y a bien 3 éléments dans la ligne
            if line.count > 2 {
                // Afficher le mot de passe en clair dans label3
                cell.label3.text = "•••••••••••••••"
            }
        }
    }
    
    
    
    // Fonction qui definit l'action de pointer une cellule
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        print("test")
        // Permet d'acceder au type personalisé (GPT)
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? nCell {

                    // On divise chaque ligne en fonction du séparateur (ex. ",")
                    let line = lines[indexPath.row].split(separator: ",") // Exemple de séparation par ","

                    // Assurez-vous qu'il y a assez de valeurs dans la ligne
                    if line.count > 0 {
                        cell.label1.text = String(line[0]) // Premier élément de la ligne
                    }
                    if line.count > 1 {
                        cell.label2.text = String(line[1]) // Deuxième élément de la ligne
                    }
                    if line.count > 2 {
                        cell.label3.text = "•••••••••••••••"
                    }

                    return cell
                }
        
        return cell
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var vue: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    
        // Ouverture du fichier
        vue.isHidden = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        vue.isHidden = true
        supprimer.isHidden = true
        copier.isHidden = true
        annuler.isHidden = true
        
        verifierBiometrie()
        RafraichirBase()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deselectionnerLigne()
        
        // Masquer la vue quand on la quitte
        vue.isHidden = true
        
    }

    
    func deselectionnerLigne() {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)

            if let cell = tableView.cellForRow(at: index) as? nCell {
                cell.label3.text = "•••••••••••••••"
            }

            supprimer.isHidden = true
            copier.isHidden = true
            annuler.isHidden = true
            supprimer.isHidden = true
            ligneSelectionnee = nil
        }
    }

    
    
    @IBAction func boutonSupprimer(_ sender: UIButton) {
        guard let index = ligneSelectionnee else {
            print("Aucune ligne sélectionnée.")
            return
        }
        
        // 1. Supprimer la ligne du tableau
        lines.remove(at: index)
        nbLignes = lines.count

        // 2. Réécrire le fichier entier
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("passwd.db")
            let nouveauContenu = lines.joined(separator: "\n") + "\n"
            
            do {
                try nouveauContenu.write(to: fileURL, atomically: true, encoding: .utf8)
                print("Ligne supprimée et fichier mis à jour.")
            } catch {
                print("Erreur lors de la mise à jour du fichier : \(error.localizedDescription)")
            }
        }

        deselectionnerLigne()
        
        // Rafraîchir la table
        tableView.reloadData()
        print("Nouvelles données : \(lines)")
    }
    
    
    @IBAction func boutonCopier(_ sender: UIButton) {
        guard let ligne = ligneSelectionnee else { return }
        
        let champs = lines[ligne].split(separator: ",")
        if champs.count >= 3 {
           let motDePasse = String(champs[2])
           UIPasteboard.general.string = motDePasse
           afficherToast(message: "Mot de passe copié !")
        }
        deselectionnerLigne()
    }
    
    
    func afficherToast(message: String, duree: Double = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height - 150, width: 300, height: 30))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14.0)
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)

        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duree, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    @IBAction func boutonAnnuler(_ sender: UIButton) {
        deselectionnerLigne()
    }
    
    
    
    
    func RafraichirBase() {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("passwd.db")

            // Vérifie si le fichier existe avant d’essayer de lire
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    let contenu = try String(contentsOf: fileURL, encoding: .utf8)
                    let temp = contenu.split(separator: "\n")
                    
                    // Tri par nom d'app alphabétique
                    lines = temp.map { String($0) }.sorted { ligne1, ligne2 in
                        let app1 = ligne1.split(separator: ",").first?.lowercased() ?? ""
                        let app2 = ligne2.split(separator: ",").first?.lowercased() ?? ""
                        return app1 < app2
                    }
                    
                    nbLignes = lines.count
                    tableView.reloadData()
                    print("Contenu actuel : \(lines)")
                } catch {
                    print("Erreur lors de la lecture du fichier: \(error.localizedDescription)")
                }
            } else {
                print("⚠️ Fichier introuvable dans Documents : \(fileURL.path)")
            }
        }
    }

    
    
    func verifierBiometrie() {
        let context = LAContext()
        var error: NSError?

        // ✅ Autorise Face ID, Touch ID ou code de l'appareil
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let raison = "Authentifiez-vous pour accéder à cette section."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: raison) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        // Authentification réussie 🎉
                        self.vue.isHidden = false
                    } else {
                        // ❌ Échec ou annulation → retour
                        self.vue.isHidden = true
                        self.fermerVueOuRetour()
                    }
                }
            }
        } else {
            // Pas de Face ID / Touch ID / code activé
            fermerVueOuRetour()
        }
    }

    func fermerVueOuRetour() {
        // Option 1 : revenir à un autre onglet
        if let tabBar = self.tabBarController {
            tabBar.selectedIndex = 0 // Revenir au 1er onglet
        }

        // Option 2 : ou masquer le contenu / afficher un écran bloqué
        // self.view.isHidden = true
    }
    
    
    
    
    // Delegate appelé quand un mot de passe est ajouté
    func didAjouterMDP() {
        RafraichirBase()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? AjouterMDPViewController {
            destination.delegate = self  // 👈 on devient le delegate
        }
    }

}
