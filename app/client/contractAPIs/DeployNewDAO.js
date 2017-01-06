

function deployNewEthenianDAO () {
  console.log("Building EthenianDAO from factory")
  deploy["deployEthenianDAOFactory"]({cb:function(e, address) {
    currentDAO.set(contracts["ethenianDAOContract"].at(addr));
    currentDAO.get().init({ from: ethAccount.get().address }, buildRegistrars);
    }
  })
}

function buildRegistrars() {
  currentDAO.get().newRegistrar("factories", { from: ethAccount.get().address }, buildFactories);
  currentDAO.get().newRegistrar("matters", { from: ethAccount.get().address });
  currentDAO.get().newRegistrar("members", { from: ethAccount.get().address });
  currentDAO.get().newRegistrar("administration", { from: ethAccount.get().address });
}

function buildFactories() {
  console.log("Building Matter factory.")
  deploy["deployMatterFactory"]({cb:registerMatterFactory});
  console.log("Building Matter factory.")
  deploy["deployMemberFactory"]({cb:registerMemberFactory});
  // deployAuthority({cb:registerAuthority});
}

function registerMatterFactory(e, contract) {
  console.log("Registering Matter factory.")  
  currentDAO.get().setRegistrarEntry("factories","matterFactory", contract.address,
    { from: ethAccount.get().address },
    function () { console.log("Matter factory registered: ", contract.address); }
  );
}

function registerMemberFactory(e, contract) {
  console.log("Registering Member factory.")  
  currentDAO.get().setRegistrarEntry("factories","matterFactory", contract.address,
    { from: ethAccount.get().address },
    function () {
      console.log("Member factory registered: ", contract.address);
    }
  );
}

function registerAuthority(e, contract) {
  console.log("Registering Matter factory.")  
  currentDAO.get().setRegistrarEntry("administration","authority", contract.address,
    { from: ethAccount.get().address },
    function () { console.log("Authority registered: ", contract.address); }
  );
}

function createAdmin(e, contract) {
  currentDAO.get().newMember("Admin", { from: ethAccount.get().address },
      function () { console.log("Admin member created:" ); }
  );
}

deploy["deployNewEthenianDAO"] = deployNewEthenianDAO;
