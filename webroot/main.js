var token = localStorage.getItem('token');

function unauthorized() {
    alert('401 - Unauthorized');
    localStorage.removeItem('token')
    location.href = '/auth';
}

function updatePerson(data) {
    data.id = parseInt(data.id);
    fetch('/api/person/' + data.id, {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Authorization': token
        },
        method: 'PUT',
        //mode: 'cors',
        cache: 'no-cache',
        body: JSON.stringify(data)
    })
    .then(response => response.status == 401 ? unauthorized() : response.json())
    .then(json => json)
    .catch(error => console.log(error));
}

function deletePerson(row) {
    var id = row.getData().id
    fetch('/api/person/' + id, {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Authorization': token
        },
        method: 'DELETE',
        //mode: 'cors',
        cache: 'no-cache'
    })
    .then(response => response.status == 401 ? unauthorized() : response)
    .then(response => row.delete())
    .catch(error => console.log(error));
}

function getPersons() {
    var config = {
      height:"auto",
      selectable:false,          //selectable rows
      layout:"fitColumns",      //fit columns to width of table
      responsiveLayout:"hide",  //hide columns that dont fit on the table
      tooltips:false,            //show tool tips on cells
      addRowPos:"top",          //when adding a new row, add it to the top of the table
      history:false,             //allow undo and redo actions on the table
      pagination:"local",       //paginate the data
      paginationSize:10,         //allow 7 rows per page of data
      movableColumns:false,      //allow column order to be changed
      resizableRows:false,       //allow row order to be changed
      initialSort:[             //set the initial sort order of the data
        {column:"lastName", dir:"asc"},
      ],
      placeholder:"No Data Set",
      //rowClick: function(e, row) { // Trigger an alert message when the row is clicked.
      //    alert("Row " + row.getData().id + " Clicked!");
      //},
      cellEdited:function(cell) {
        updatePerson(cell.getRow().getData());
      },
      columns:[
          {title:"Id", field:"id", sorter:"number", width:320, headerFilter:true, validator:"required"},
          {title:"Lastname", field:"lastName", sorter:"string", editor:"input", headerFilter:true, validator:"required"},
          {title:"Firstname", field:"firstName", sorter:"string", editor:"input", headerFilter:true, validator:"required"},
          {title:"Email", field:"email", editor:"input", headerFilter:true, validator:"required"},
          {formatter:"buttonCross", width:40, align:"center", headerSort:false, cellClick:function(e, cell) {
                  if (confirm('Are you sure you want to delete this entry?')) {
                      deletePerson(cell.getRow());
                  }
              }
          }
      ],
    }
    var table = new Tabulator("#content", config);
    table.setData("/api/person");
    
    var btn = document.createElement("BUTTON");
    btn.setAttribute("title", "New");
    btn.setAttribute("class", "tabulator-page");
    btn.setAttribute("style", "float: left");
    btn.onclick = function(){
        var data = {id: 0, firstName: "", lastName: "", email: ""};
        fetch('/api/person', {
              headers: {
                  'Content-Type': 'application/json;charset=UTF-8',
                  'Authorization': token
              },
              method : 'POST',
              //mode: 'cors',
              cache: 'no-cache',
              body: JSON.stringify(data)
        })
        .then(response => response.status == 401 ? unauthorized() : response.json())
        .then(json => {
              data.id = json.id;
              table.addRow(data);
        })
        .catch(error => console.log(error));
    };
    var t = document.createTextNode("+ New");
    btn.appendChild(t);
    document.getElementsByClassName("tabulator-paginator")[0].prepend(btn);
}
