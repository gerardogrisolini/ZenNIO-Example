var token = localStorage.getItem('token');

function unauthorized() {
    alert('401 - Unauthorized');
    location.href = '/auth';
}

function savePerson(data) {
    if (data.id === '00000000-0000-0000-0000-000000000000') {
        insertPerson(data);
    } else {
        updatePerson(data)
    }
}

function insertPerson(data) {
    fetch('/api/person', {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Authorization': token
        },
        method : 'POST',
        cache: 'no-cache',
        body: JSON.stringify(data)
    })
    .then(response => response.status == 401 ? unauthorized() : response.json())
    .then(json => console.log('Insert person id ' + json.id))
    .catch(error => console.log(error));
}

function updatePerson(data) {
    fetch('/api/person/' + data.id, {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Authorization': token
        },
        method : 'PUT',
        cache: 'no-cache',
        body: JSON.stringify(data)
    })
    .then(response => response.status == 401 ? unauthorized() : response.json())
    .then(json => console.log('Update person id ' + json.id))
    .catch(error => console.log(error));
}

function deletePerson(row) {
    var id = row.getData().id
    fetch('/api/person/' + id, {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Authorization': token
        },
        method : 'DELETE',
        cache: 'no-cache'
    })
    .then(response => response.status == 401 ? unauthorized() : response)
    .then(response => { row.delete(); console.log('Delete person id ' + id); })
    .catch(error => console.log(error));
}

function getPersons() {
    var table = new Tabulator("#content", {
                              height:"auto",
                              selectable:true,          //selectable rows
                              layout:"fitColumns",      //fit columns to width of table
                              responsiveLayout:"hide",  //hide columns that dont fit on the table
                              tooltips:false,            //show tool tips on cells
                              addRowPos:"top",          //when adding a new row, add it to the top of the table
                              history:false,             //allow undo and redo actions on the table
                              pagination:"local",       //paginate the data
                              paginationSize:5,         //allow 7 rows per page of data
                              movableColumns:false,      //allow column order to be changed
                              resizableRows:false,       //allow row order to be changed
                              initialSort:[             //set the initial sort order of the data
                                {column:"lastName", dir:"asc"},
                              ],
                              placeholder:"No Data Set",
                              //rowClick: function(e, row) { // Trigger an alert message when the row is clicked.
                              //    alert("Row " + row.getData().id + " Clicked!");
                              //},
                              cellEdited:function(cell){
                                savePerson(cell.getRow().getData());
                              },
                              columns:[
                                  {title:"Uuid", field:"id", sorter:"string", width:320, headerFilter:true, validator:"required"},
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
                          });
    table.setData("/api/person");
    
    var btn = document.createElement("BUTTON");
    btn.setAttribute("title", "New");
    btn.setAttribute("class", "tabulator-page");
    btn.setAttribute("style", "float: left");
    btn.onclick = function(){
        table.addRow({id: "00000000-0000-0000-0000-000000000000"});
    };
    var t = document.createTextNode("+ New");
    btn.appendChild(t);
    document.getElementsByClassName("tabulator-paginator")[0].prepend(btn);
}

/*
function getPerson(id) {
    fetch('/api/person/' + id, {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8'
        },
        method : 'GET',
        cache: 'no-cache'
    })
    .then(response => response.json())
    .then(json => selectPerson(json.id, json.firstName, json.lastName, json.email))
    .catch(error => console.log(error));
}

function getPersons() {
    document.getElementById('content').innerHTML = '';
    fetch('http://192.168.1.10:8080/api/person', {
        headers: {
            'Origin': '*',
            'Content-Type': 'application/json;charset=UTF-8'
        },
        method : 'GET',
        cache: 'no-cache',
        mode: 'cors'
    })
    .then(response => response.json())
    .then(json => showPersons(json))
    .catch(error => console.log(error));
}

function showPersons(json) {
    for (i = 0; i < json.length; i++) {
        div = json[i].firstName + ' ' + json[i].lastName;
        div += ' <button onclick="selectPerson(\'' + json[i].id + '\', \'' + json[i].firstName + '\', \'' + json[i].lastName + '\', \'' + json[i].email + '\')">Edit</button>';
        div += ' <button onclick="getPerson(\'' + json[i].id + '\')">Open</button>';
        div += ' <button onclick="deletePerson(\'' + json[i].id + '\')">Delete</button>';
        document.getElementById('content').innerHTML += div;
    }
}
*/
