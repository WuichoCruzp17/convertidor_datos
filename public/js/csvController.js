document.addEventListener('DOMContentLoaded', function () {
    const csvFileInput = document.getElementById('csvFileInput');
    const uploadButton = document.getElementById('uploadButton');
    const encabezado ="<th>${titulo}</th>";
    const informacion ="<td>${info}</td>"
    uploadButton.addEventListener('click', function () {
      const selectedFile = csvFileInput.files[0];

      if (selectedFile) {
        const formData = new FormData();
        formData.append('csv_file', selectedFile);

        // Obtiene el token CSRF del meta tag en el HTML
        const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

        fetch('/convertidor_csv/upload', {
          method: 'POST',
          headers: {
            'X-CSRF-Token': csrfToken, // Incluye el token CSRF en el encabezado
          },
          body: formData
        })
          .then(response => response.json())
          .then(data => {
            // Maneja la respuesta del servidor, si es necesario
            console.log(data);
            tabla(data.tabla)
            document.getElementById("comment").value = data.xml
            document.getElementById("json").value = JSON.stringify(listToTree(data.tabla),null,1)

          })
          .catch(error => {
            console.error('Error al subir el archivo:', error);
          });
      } else {
        alert('Selecciona un archivo antes de hacer clic en "Subir Archivo".');
      }
    });

    function tabla(data){
        var tabla =`<thead>
            <tr>${getColumnas(data)} </tr>
            </thead>
            <tbody>
            <tr>
            ${getData(data)}
            </tbody>`;

        document.getElementById("table").innerHTML=tabla
    }

    function getColumnas(data){
        var col =""
        col =encabezado.replace("${titulo}","#")
        if(Array.isArray(data)){
            const columnas = Object.keys(data[0])
            for(var i=0; i<columnas.length;i++){
                col=col+encabezado.replace("${titulo}",columnas[i])
            }
        }
        return col;
    }

    function getData(data){
        var info = "";
        if(Array.isArray(data)){
            const columnas = Object.keys(data[0])
            for(var i=0;i<data.length;i++){
                info=info+"<tr>";
                info=info+informacion.replace("${info}",(i+1))
                for(var y=0; y<columnas.length;y++){
                    info=info+informacion.replace("${info}",data[i][columnas[y]])

                }
                info=info+"</tr>"
            }

        }
        return info
    }

    function listToTree(list){
      // Diccionario de referencias, para no tener que estar dando varias pasadas,
      // ya que no hay garantia de que los padres elementos estén ordenados por id
      // o que los padres tengan IDs de valor menor a sus hijos.
      var dictionary = {};
      var tree = [];
      for(var i = 0;i < list.length; i++){
        var element = {};
        for(var x in list[i]){
          // Clon
          element[x] = list[i][x];
        }
        // Si existe un padre temporal, recuperamos la lista de hijos.
        element.hijos = dictionary[element.id] ? dictionary[element.id].hijos: [];
        dictionary[element.id] = element;

        if(element.id_padre){
          // Si no existe el padre en el diccionario, creamos un padre temporal
          // Esto es parte de la estrategia para no tener que iterar varias veces
          if(!dictionary[element.id_padre]){
            dictionary[element.id_padre] = { id:element.id_padre, hijos: [] };
          }
          dictionary[element.id_padre].hijos.push(element);
        }
        else{
          // Es un padre y se agrega a la raiz del arbol. Se asume que pueden existir multiples padres.
          tree.push(element);
        }
      }
      return tree.length === 1 ? tree[0] : tree ;//Si solo hay un padre, se envía solo ese objeto en lugar del arreglo completo.
    }
  });
