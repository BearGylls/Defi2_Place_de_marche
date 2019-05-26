pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract PlaceDeMarche {
    using SafeMath for uint256;

    mapping (address => uint256) repu;
    mapping (address => string) nom;
    mapping (address => mapping (string => address)) adresseParticipant;
    mapping (address => bool) adressesBannies;
    mapping (address => bool) admins;
    mapping (address => string) entreprise;
    mapping (address => bool) estEntreprise;
    mapping (address => bool) estInscrit;
    mapping (address => bool) estIllustrateur;
    mapping (address => string) illustrateur;    
    mapping (string  => Demande) offresAcceptees;
    
    enum etatDemande {Ouverte,EnCours,Fermee}
    struct Demande {
        uint indice;
        uint remuneration;
        uint delaiAvantRendu;
        string descriptionTache;
        uint reputationRequise;
        etatDemande etatDem;
        string[] candidats;
        mapping (address => bool) entrepriseCreatriceDeLOffre;
    }
    Demande[] demandes;
    etatDemande[] etatDemandeTraitee;
    mapping (address => bytes32) hashTravail; 

    // Code à réccup coté client
    //Demande offreVisee;
    
    constructor() public payable{
        admins[msg.sender]=true;
    }

    function()external payable {
        require(msg.data.length == 0);
    }
    
    function nomerAdministrateur(address newAdmin) public {
        require(admins[msg.sender]);
        admins[newAdmin]=true;
    }

    function inscription(string memory _nom) public {
        //require(!adressesBannies[msg.sender],"Vous ne pouvez plus accéder à la place de marché, vous avez été banni");
        //require((!estInscrit[msg.sender])||(estInscrit[msg.sender] && estEntreprise[msg.sender])||(estInscrit[msg.sender] && estIllustrateur[msg.sender]), "Vous êtes déjà inscrit");
        // Si déjà inscrit (champs vide géré côté interface) 
        //if(adresseParticipant[msg.sender][nom[msg.sender]]==msg.sender){
        if(estInscrit[msg.sender]){
            if(estEntreprise[msg.sender]){ // Alors il veut s'inscrir en tant qu'artiste
                estIllustrateur[msg.sender]= true;
                illustrateur[msg.sender]=_nom;
                adresseParticipant[msg.sender][illustrateur[msg.sender]]=msg.sender;
            }
            else{
                estEntreprise[msg.sender]= true;
                entreprise[msg.sender]=_nom;
            }
        }
        // Sous forme de if ?    require(nom[_nom] != msg.sender);
        else{
            repu[msg.sender]=1;
            nom[msg.sender]=_nom;
            adresseParticipant[msg.sender][nom[msg.sender]]=msg.sender;     // On range l'adresse du participant aussi grace à son nom | utile ?
            estInscrit[msg.sender]=true;
        }
    }

    /**************  Fonctions de Test  **************/
    function getIllustrateurs() public view returns (string memory)  {
        return illustrateur[msg.sender];
    }

    function getEntreprise() public view returns (string memory) {
        return entreprise[msg.sender];
    }
    
    function estEntrepriseCreatriceOffre(uint _index) public view returns (bool){
        return demandes[_index].entrepriseCreatriceDeLOffre[msg.sender];
    }
    
    function getCandidat(uint _indiceDemande, uint _indiceCandidat) public view returns (string memory) {
        return demandes[_indiceDemande].candidats[_indiceCandidat];
    }
 
    function fetLevelReputation() public view returns (uint) {
        return repu[msg.sender];
    }
 /*
    function getOffreEnCours() public view returns (bool) {
        if(offresAcceptees[illustrateur[msg.sender]].indice == demandes[offresAcceptees[illustrateur[msg.sender]].indice].candidats[offresAcceptees[illustrateur[msg.sender]].indice]){
            return true;
        }
        else{
            return false;
        }
    }*/
    
    /********************************************************/
    
    function banAdresse(address addABan) private {
        require(admins[msg.sender]);
        repu[addABan]=0;
        adressesBannies[addABan]=true;
    }

    function ajouterDemande(/*uint versement,*/ uint _remuneration, uint _delaiAvantRendu, string memory _descriptionTache, uint _reputationRequise) public payable {
        // ----- require(nom[msg.sender] != ""); // autre moeyn ?
        require(estInscrit[msg.sender]);
       // require(msg.sender.balance >= versement);
        require(msg.value == (_remuneration + (_remuneration/100).mul(2)), "Vous vous êtes trompé, votre versement est trop petit ou trop grand.");
        if(estIllustrateur[msg.sender]){
            require(estEntreprise[msg.sender], "Inscrivez vous d'abord en tant qu'entreprise");
        }
        //msg.value = versement;
        // Création de la demande
        Demande memory dmd;
        dmd.remuneration = _remuneration;
        dmd.delaiAvantRendu = _delaiAvantRendu;
        dmd.descriptionTache = _descriptionTache;
        dmd.etatDem = etatDemande.Ouverte;
        dmd.reputationRequise = _reputationRequise;
        //dmd.entrepriseCreatriceDeLOffre[msg.sender]=true;
        demandes.push(dmd);
        demandes[demandes.length-1].entrepriseCreatriceDeLOffre[msg.sender]=true;
        // Blocage des fonds et paiement de la plateforme
        address(this).transfer(msg.value);
        // ajout du participant comme entreprise
        estEntreprise[msg.sender]=true;
        entreprise[msg.sender]=nom[msg.sender];
    }

    function postuler(uint _indiceOffreVisee) public {
        require(estInscrit[msg.sender]);
        require(repu[msg.sender]>= demandes[_indiceOffreVisee].reputationRequise); // Mais pas besoin si géré par l'interface 
        //require(!demandes[_indiceOffreVisee].estEntrepriseCreatriceOffre[msg.sender],"Vous ne pouvez postuler à votre propre offre");
        
        if(estEntreprise[msg.sender]){
            require(estIllustrateur[msg.sender],"Inscrivez vous d'abord en tant qu'illustrateur");
        }
        else{
            estIllustrateur[msg.sender]=true;
            illustrateur[msg.sender]=nom[msg.sender];            
        }
        demandes[_indiceOffreVisee].candidats.push(nom[msg.sender]);
    }

    function accepterOffre(uint _indiceDemande, string memory _illustrateurAccepte) public {
        require(demandes[_indiceDemande].entrepriseCreatriceDeLOffre[msg.sender]);
        demandes[_indiceDemande].etatDem = etatDemande.EnCours;
        offresAcceptees[_illustrateurAccepte]= demandes[_indiceDemande];
    }

    function paiement() public payable {
        msg.sender.transfer(msg.value);
    }

    function livraison(bytes32 hash) public payable returns (string memory) {
        require(estIllustrateur[msg.sender]);
        
        uint remu = offresAcceptees[illustrateur[msg.sender]].remuneration;
        hashTravail[msg.sender]=hash;
        repu[msg.sender]++;
        msg.sender.transfer(remu);
        
        return "Vous pouvez désormais retirer vos fonds.";
    }
}