using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;


public class MeshData
{
    public List<Vector3> vertices; // The vertices of the mesh 
    public List<int> triangles; // Indices of vertices that make up the mesh faces
    public Vector3[] normals; // The normals of the mesh, one per vertex

    // Class initializer
    public MeshData()
    {
        vertices = new List<Vector3>();
        triangles = new List<int>();
    }

    // Returns a Unity Mesh of this MeshData that can be rendered
    public Mesh ToUnityMesh()
    {
        Mesh mesh = new Mesh
        {
            vertices = vertices.ToArray(),
            triangles = triangles.ToArray(),
            normals = normals
        };

        return mesh;
    }

    // Calculates surface normals for each vertex, according to face orientation
    public void CalculateNormals()
    {
        normals = new Vector3[vertices.Count];

        var trianglesNormals = new Dictionary<int[], Vector3>();
        for (var i = 0; i < triangles.Count; i += 3)
        {
            var key = new[] { triangles[i], triangles[i + 1], triangles[i + 2] };
            var p1 = vertices[triangles[i]];
            var p2 = vertices[triangles[i + 1]];
            var p3 = vertices[triangles[i + 2]];
            trianglesNormals[key] = Vector3.Cross((p1 - p3), (p2 - p3)).normalized;
        }

        for (var i = 0; i < vertices.Count; i++)
        {
            var vNormals = new List<Vector3>();
            foreach (var item in trianglesNormals)
            {
                if (item.Key.Contains(i))
                {
                    vNormals.Add(item.Value);
                }
            }

            var res = Vector3.zero;
            foreach (var n in vNormals)
            {
                res += n;
            }

            normals[i] = res.normalized;
        }
    }

    // Edits mesh such that each face has a unique set of 3 vertices
    public void MakeFlatShaded()
    {
        var seenV = new HashSet<int>();        
        for (var i = 0; i < triangles.Count; i++)
        {
            if (seenV.Contains(triangles[i]))
            {
                var newV = vertices[triangles[i]];
                vertices.Add(newV);
                triangles[i] = vertices.Count - 1;
            }
            else
            {
                seenV.Add(triangles[i]);
            }
        }
    }
}