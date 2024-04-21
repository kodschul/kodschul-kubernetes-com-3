# Kubernetes: Bereitstellung von Datenspeichern: Einfache Volumes und Persistente Volumes

In Kubernetes können verschiedene Arten von Datenspeichern bereitgestellt werden, um persistente Daten für Anwendungen zu speichern. Zu den grundlegenden Konzepten gehören einfache Volumes und persistente Volumes (PVs). Im Folgenden werden beide Konzepte erläutert:

## Einfache Volumes

Ein einfaches Volume in Kubernetes ist ein Verzeichnis, das von einem Pod genutzt wird und dessen Lebensdauer an die Lebensdauer des Pods gebunden ist. Wenn der Pod beendet wird, wird das Volume ebenfalls gelöscht. Einfache Volumes sind für temporäre Daten geeignet. Hier ist ein einfaches Beispiel:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mycontainer
    image: myimage
    volumeMounts:
    - name: myvolume
      mountPath: /data
  volumes:
  - name: myvolume
    emptyDir: {}
```

In diesem Beispiel wird ein einfaches Volume mit einem leeren Verzeichnis (emptyDir) definiert. Es wird im Pod mypod eingehängt und steht unter dem Pfad /data zur Verfügung.

## Persistente Volumes (PVs)
Persistente Volumes (PVs) sind unabhängige, persistente Speicherressourcen in Kubernetes, die von Pods genutzt werden können. Im Gegensatz zu einfachen Volumes haben PVs eine längere Lebensdauer und überleben das Beenden von Pods. Hier ist ein Beispiel für die Definition eines persistenten Volumes:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
```

In diesem Beispiel wird ein persistenter Volume mit einem Speicherplatz von 1 GB und einem Zugriffsmodus von "ReadWriteOnce" definiert. Es verwendet ein Host-Verzeichnis unter /mnt/data.

Um ein persistentes Volume in einem Pod zu verwenden, muss ein PersistentVolumeClaim (PVC) erstellt werden, das das PV anfordert. Hier ist ein Beispiel für die Verwendung eines PVC in einem Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mycontainer
    image: myimage
    volumeMounts:
    - name: myvolume
      mountPath: /data
  volumes:
  - name: myvolume
    persistentVolumeClaim:
      claimName: mypvc
```

Dieses Beispiel zeigt einen Pod mypod, der ein persistentes Volume über einen PersistentVolumeClaim mypvc verwendet.