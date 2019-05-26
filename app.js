let user = {}
let dapp = {}

function ajouterArtiste(){
  let artiste = document.getElementById("nomartiste").value
  dapp.ContratSigner.inscription(artiste)
  rafraichir()
}

function afficheArt(){
  //rafraichir()
  let toto =  dapp.Contrat.getIllustrateurs()
  //let toto = await dapp.Contrat.getIllustrateurs()
  document.getElementById("afficheArtiste").innerHTML = toto
  console.log(toto)
  rafraichir()
}

async function connectMetamask() {
  try {
    const addresses = await ethereum.enable()
    user.address = addresses[0]
    const provider = new ethers.providers.Web3Provider(ethereum)
    // const provider = new ethers.getDefaultProvider("kovan")
    let Contrat=new ethers.Contract(contractAddress, contractABI, provider)
    let ContratSigner=Contrat.connect(provider.getSigner(user.address))

    dapp = { provider, Contrat, ContratSigner}

    console.log("DApp ready: ", dapp)
    console.log("User ready: ", user)
    rafraichir()
  } catch(err) {
    console.error(err);
  }
}
connectMetamask()

async function rafraichir() {
  dapp.provider.getNetwork().then(
    ntw => {document.getElementById("network").innerHTML = JSON.stringify(ntw);
    console.log(ntw)  
  })
  //let creneauxLibres = await dapp.Contrat.creneauxLibres()
  //document.getElementById("creneaux").innerHTML = creneauxLibres
 // let encours = await dapp.Contrat.getIllustrateurs()
  //document.getElementById("encours").innerHTML = encours

  for (var i = 0; i <12; i++) {
    let artiste= await dapp.Contrat.utilisateurs(i)
    let  listitem = document.createElement("li") //
    listitem.innerHTML = ` ⭐ ${artiste} ⭐ `
    document.getElementById("liste").appendChild(listitem)
    
  }
}


