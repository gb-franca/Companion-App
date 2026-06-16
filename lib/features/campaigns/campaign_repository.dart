import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/db_helper.dart';
import 'campaign_model.dart';

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return CampaignRepository(dbHelper);
});

class CampaignRepository {
  final DbHelper _dbHelper;

  CampaignRepository(this._dbHelper);

  Future<List<Campaign>> getAllCampaigns() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DbHelper.tableCampaigns);
    return List.generate(maps.length, (i) => Campaign.fromMap(maps[i]));
  }

  Future<int> insertCampaign(Campaign campaign) async {
    final db = await _dbHelper.database;
    return await db.insert(DbHelper.tableCampaigns, campaign.toMap());
  }

  Future<int> updateCampaign(Campaign campaign) async {
    final db = await _dbHelper.database;
    return await db.update(
      DbHelper.tableCampaigns,
      campaign.toMap(),
      where: '${DbHelper.colId} = ?',
      whereArgs: [campaign.id],
    );
  }

  Future<int> deleteCampaign(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DbHelper.tableCampaigns,
      where: '${DbHelper.colId} = ?',
      whereArgs: [id],
    );
  }
}
