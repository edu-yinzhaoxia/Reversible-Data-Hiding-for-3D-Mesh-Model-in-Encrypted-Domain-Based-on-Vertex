This code is the implementation of the paper "Reversible Data Hiding for 3D Mesh Model in Encrypted Domain Based on Vertex
Partition and Coordinate Standardization".

## Abstract
Reversible data hiding in encrypted domain enables the secure and confidential embedding of additional
information in encrypted multimedia, ensuring the privacy and integrity of both the carrier and the embedded data during
transmission. The authorized recipients can extract the data without any loss and recover the media successfully. In the
realm of digital media, 3D mesh models, being a relatively nascent form, possesses a distinctive file structure markedly
different from that of conventional image media. Consequently, limited research has been conducted in this domain.
Augmenting the embedding capacity of 3D mesh models in the encrypted domain poses an enduring challenge. The
direct application of multiple most significant bit prediction algorithm from the image domain to 3D mesh models is
impeded by disparities in data storage formats, thus encumbering the predictive performance of algorithms. To
effectively tackle this issue, we propose the adoption of coordinate standardization to eliminate the influence of the sign
bit and ameliorate the prediction algorithm’s overall performance. In order to further mitigate the inclusion of redundant
auxiliary information, we introduce the integration of the selection of embedding set vertices into our experiments,
which effectively generates additional payload space. The experimental results affirm that our purposed methodology
attains the maximum embedding capacity while guaranteeing lossless and separable recovery of both the model and the
embedded information, surpassing the capabilities of existing techniques.
## 摘要
密文可逆信息隐藏技术可以在加密载体中利用冗余空间额外嵌入信息，在传输过程中保障载体和信息的
隐私安全，载体接收者还可以实现无损地提取信息和恢复载体.3 维网格模型作为新型的数字媒体，其文件结构
与传统的图像等数字媒体存在着不同，并且在该领域的研究相对较少.如何提升模型的嵌入容量是目前需要解
决的问题.将图像领域多个高有效位预测算法直接迁移到 3 维模型中应用时，由于数据的存储格式与图像媒体
不同，使得算法的预测性能受到了限制.因此， 提出了将顶点坐标值标准化处理，消除符号位带来的影响，提
升了预测算法的性能.为了进一步减少无用的辅助信息，嵌入集顶点的筛选被加入实验中，成功地为有效载荷
腾出空间.实验表明， 提出的方法与现有方法相比， 在保证无损和可分离地恢复模型与所嵌入的信息的同时，
获得了最高的嵌入容量.

## How to cite our paper
  @article{ JFYZ20230920003,
  author = { 吕皖丽, 唐运, 殷赵霞 & 罗斌 },
  title = {基于顶点划分和坐标标准化的密文域3维网格模型可逆信息隐藏},
  journal = {计算机研究与发展},
  number = {1-13},
  issn = {1000-1239},
  }
